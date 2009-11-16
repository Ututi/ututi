from xmlrpclib import ServerProxy

from pylons import config


def send_message(uin, message):
    username = config.get('nous_im_username')
    password = config.get('nous_im_password')
    p = ServerProxy('http://%s:%s@localhost:6001' % (username, password))
    return p.send_gg_msg(uin, message)
