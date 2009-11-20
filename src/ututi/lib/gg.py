from datetime import datetime
from hashlib import md5
from xmlrpclib import ServerProxy

from paste.util.converters import asbool
from pylons import config

sent_messages = []

def send_message(uin, message):
    hold = asbool(config.get('hold_emails', 'false'))
    if not hold:
        username = config.get('nous_im_username')
        password = config.get('nous_im_password')
        p = ServerProxy('http://%s:%s@localhost:6001' % (username, password))
        return p.send_gg_msg(uin, message)
    else:
        sent_messages.append((uin, message))


def confirmation_request(user):
    hash = md5(datetime.now().isoformat() + str(user.gadugadu_uin)).hexdigest()
    hash = hash[:5]
    user.gadugadu_confirmation_key = hash
    send_message(user.gadugadu_uin, hash)
