import sys, time, os
import logging
from daemon import Daemon
from urllib import urlencode
from urllib2 import urlopen, URLError
from threading import BoundedSemaphore

class MyDaemon(Daemon):
    def run(self):
        # database connect

        log_file = os.environ.get('SMSD_LOG_FILE')
        logging.basicConfig(filename=log_file,
                            format='%(asctime)s %(levelname)-8s %(message)s',
                            datefmt='%a, %d %b %Y %H:%M:%S',
                            level=logging.DEBUG)

        logging.info('SMSD started')

        from sqlalchemy import engine_from_config
        from paste.deploy.loadwsgi import ConfigLoader
        config_file = os.environ['SMSD_CONFIG_FILE']
        clo = ConfigLoader(config_file)

        config = dict(clo.parser.items('app:main'))
        engine = engine_from_config(config)
        connection = engine.connect()

        sms_url = config.get('sms.url')
        sms_user = config.get('sms.user')
        sms_password = config.get('sms.password')
        sms_from = config.get('sms.from')
        sms_dlr_url = config.get('sms.dlr-url')
        sms_dlr_mask = config.get('sms.dlr-mask')

        sms_thread_count = config.get('sms.thread_count', 5)
        sending_sema = BoundedSemaphore(sms_thread_count)

        while True:
            results = list(connection.execute("select id, recipient_number, message_text\
                                               from sms_outbox where sending_status is null\
                                               and delivery_status is null\
                                               and (processed is null or processed < (now() at time zone 'UTC') - interval '1 minute')\
                                               order by created asc limit 5"))
            for result in results:

                #fork
                pid = os.fork()

                if pid:
                    continue
                else:
                    # XXX Semaphores probably won't work as expected with fork().
                    sending_sema.acquire()
                    sms_id, sms_to, sms_text = result
                    message = {
                        'user': sms_user,
                        'password': sms_password,
                        'to': sms_to,
                        'from': sms_from,
                        'dlr-mask': sms_dlr_mask,
                        'dlr-url': sms_dlr_url % sms_id,
                        'text': sms_text}
                    url = '%s?%s' % (sms_url, urlencode(message))

                    #processing time should not be rolled back
                    results = connection.execute("update sms_outbox set processed = (now() at time zone 'UTC') where id = %d" % sms_id)
                    tx = connection.begin()
                    try:
                        response = urlopen(url)
                        msg = response.read()
                        status, message = msg.split(';')

                        status = int(status)
                        results = connection.execute("update sms_outbox set sending_status = %d where id = %d" % (status, sms_id))
                        log.debug('SMS send (sms id %d)', sms_id)
                        tx.commit()
                    except ValueError:
                        log.error('Invalid responce from SMSC: %s (sms id %d)', (msg, sms_id))
                        tx.rollback()
                    except URLError:
                        log.error('SMSC connection error (sms id %d)', sms_id)
                        tx.rollback()
                        #TODO: logging
                    finally:
                        sending_sema.release()
                        os._exit(os.EX_OK)
            time.sleep(5)


def main():

    pid_file = os.environ.get('SMSD_PID_FILE', 'smsd.pid')
    pid_file = os.path.abspath(pid_file)
    daemon = MyDaemon(pid_file)
    config_file = sys.argv[1] if len(sys.argv) > 2 else 'development.ini'

    config_file = os.path.abspath(config_file)
    os.environ['SMSD_CONFIG_FILE'] = config_file

    pgport = os.environ.get("PGPORT", "4455")
    os.environ["PGPORT"] = pgport 

    log_file = os.environ.get("SMSD_LOG_FILE", 'smsd.log')
    log_file = os.path.abspath(log_file)
    os.environ['SMSD_LOG_FILE'] = log_file

    if len(sys.argv) == 2:
        if 'start' == sys.argv[1]:
            daemon.start()
        elif 'stop' == sys.argv[1]:
            daemon.stop()
        elif 'restart' == sys.argv[1]:
            daemon.restart()
        else:
            print "Unknown command"
            sys.exit(2)
            sys.exit(0)
    else:
        print "usage: %s start|stop|restart" % sys.argv[0]
        sys.exit(2)
