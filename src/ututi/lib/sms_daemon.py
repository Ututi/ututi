import sys, time, os
from daemon import Daemon
from urllib import urlencode
from urllib2 import urlopen, URLError

class MyDaemon(Daemon):
    def run(self):
        # database connect
        from sqlalchemy import engine_from_config
        from paste.deploy.loadwsgi import ConfigLoader
        config_file = os.environ['CONFIG_FILE']
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

        while True:
            results = list(connection.execute("select id, recipient_number, message_text\
                                               from sms_outbox where sending_status is null\
                                               and delivery_status is null\
                                               and (processed is null or processed < (now() at time zone 'UTC') - interval '1 minute')\
                                               order by created asc limit 5"))
            for result in results:
                sms_id, sms_to, sms_text = result
                #out = open("/home/domas/results.txt", "a")
                #out.write("%d -> %s : %s \n" % tuple(result))
                #out.close()
                message = {
                    'user': sms_user,
                    'password': sms_password,
                    'to': sms_to,
                    'from': sms_from,
                    'dlr-mask': sms_dlr_mask,
                    'dlr-url': sms_dlr_url % sms_id,
                    'text': sms_text}
                url = '%s?%s' % (sms_url, urlencode(message))
                results = connection.execute("update sms_outbox set processed = (now() at time zone 'UTC') where id = %d" % sms_id)
                urlopen(url)
                time.sleep(1)
            time.sleep(5)

def main():
    daemon = MyDaemon('/tmp/daemon-example.pid')
    config_file = sys.argv[1] if len(sys.argv) > 2 else 'development.ini'

    config_file = os.path.abspath(config_file)
    os.environ['CONFIG_FILE'] = config_file
    pgport = os.environ.get("PGPORT", "4455")
    os.environ["PGPORT"] = pgport 

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
