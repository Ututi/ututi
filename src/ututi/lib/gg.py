import os
import logging

from datetime import datetime
from hashlib import md5
from xmlrpclib import ServerProxy

from paste.util.converters import aslist
from paste.util.converters import asbool
from pylons import config

from pylons.i18n import _

log = logging.getLogger(__name__)

sent_messages = []

def send_message(uin, message):
    hold = asbool(config.get('hold_emails', 'false'))

    force_gg_to = aslist(os.environ.get("ututi_force_gg_to", []), ',',
                         strip=True)
    force_gg_to = [int(gg) for gg in force_gg_to if gg]

    log.debug("%s -> %r" % (uin, message))

    if not hold or uin in force_gg_to:
        username = config.get('nous_im_username')
        password = config.get('nous_im_password')
        p = ServerProxy('http://%s:%s@localhost:6001' % (username, password))
        try:
            result = p.send_gg_msg(uin, message)
        except:
            result = "FAIL"
        return result
    else:
        sent_messages.append((uin, message))


def confirmation_request(user):
    hash = md5(datetime.now().isoformat() + str(user.gadugadu_uin)).hexdigest()
    hash = hash[:5]
    user.gadugadu_confirmation_key = hash
    msg = _("To confirm your gadu gadu enter this code in your profile page.")
    send_message(user.gadugadu_uin, msg)
    send_message(user.gadugadu_uin, hash)
