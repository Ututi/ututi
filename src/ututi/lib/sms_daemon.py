import sys, time, os
import logging
from daemon import Daemon
from urllib import urlencode
from urllib2 import urlopen, URLError
from threading import BoundedSemaphore, Thread

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

        sms_config = {
            'url' : config.get('sms.url'),
            'user' : config.get('sms.user'),
            'password' : config.get('sms.password'),
            'from' : config.get('sms.from'),
            'dlr-url' : config.get('sms.dlr-url'),
            'dlr-mask' : config.get('sms.dlr-mask')}

        sms_thread_count = config.get('sms.thread_count', 5)
        sending_sema = BoundedSemaphore(sms_thread_count)

        while True:
            results = list(connection.execute("select id, recipient_number, message_text\
                                               from sms_outbox where sending_status is null\
                                               and delivery_status is null\
                                               and (processed is null or processed < (now() at time zone 'UTC') - interval '1 minute')\
                                               order by created asc limit 5"))
            for result in results:
                thr = SenderThread(sending_sema, engine, tuple(result), sms_config, logging)
                thr.start()

            time.sleep(5)


def main():

    pid_file = os.environ.get('SMSD_PID_FILE', 'smsd.pid')
    pid_file = os.path.abspath(pid_file)

    config_file = os.environ.get('SMSD_CONFIG_FILE', 'development.ini')
    config_file = os.path.abspath(config_file)
    os.environ['SMSD_CONFIG_FILE'] = config_file

    pgport = os.environ.get("PGPORT", "4455")
    os.environ["PGPORT"] = pgport 

    log_file = os.environ.get("SMSD_LOG_FILE", 'smsd.log')
    log_file = os.path.abspath(log_file)
    os.environ['SMSD_LOG_FILE'] = log_file

    daemon = MyDaemon(pid_file)

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


class SenderThread(Thread):
    def __init__(self, semaphore, db_engine, sms, sms_config, log):
        Thread.__init__(self)
        self.semaphore = semaphore
        self.sms = sms
        self.db_engine = db_engine
        self.sms_config = sms_config
        self.log = log

    def run(self):
        self.semaphore.acquire()

        connection = self.db_engine.connect()

        sms_id, sms_to, sms_text = self.sms
        sms_text = sms_text.decode('utf-8')

        coding=1
        try:
            sms_text = sms_text.encode('ascii')
        except UnicodeError:
            sms_text = sms_text.encode('utf-16be')
            coding=2

        message = {
            'user': self.sms_config['user'],
            'password': self.sms_config['password'],
            'to': sms_to,
            'from': self.sms_config['from'],
            'dlr-mask': self.sms_config['dlr-mask'],
            'dlr-url': self.sms_config['dlr-url'] % sms_id,
            'text': sms_text}

        # apparently coding=1 does not mean ascii
        if coding != 1:
            message['coding'] = coding

        url = '%s?%s' % (self.sms_config['url'], urlencode(message))

        #processing time should not be rolled back
        results = connection.execute("update sms_outbox set processed = (now() at time zone 'UTC') where id = %d" % sms_id)
        self.log.debug('Message text (sms is %d): %s', (sms_id, sms_text))
        self.log.debug('Sending sms (sms id %d): %s' % (sms_id, url))
        tx = connection.begin()
        try:
            response = urlopen(url)
            msg = response.read()
            status, message = msg.split(';')

            status = int(status)
            results = connection.execute("update sms_outbox set sending_status = %d where id = %d" % (status, sms_id))
            self.log.info('SMS sent (sms id %d)', sms_id)
            tx.commit()
        except ValueError:
            self.log.error('Invalid response from SMSC: %s (sms id %d)', (msg, sms_id))
            tx.rollback()
        except URLError:
            tx.rollback()
            self.log.error('SMSC connection error (sms id %d)', sms_id )
        finally:
            connection.close()
            self.semaphore.release()
