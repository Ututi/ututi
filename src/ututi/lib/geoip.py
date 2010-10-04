import os
import pygeoip
import ututi

from pylons import request
from ututi.model import meta

GEOIP_DB_PATH = os.path.join(ututi.__path__[0], '..', 'GeoIPCity.dat')
gi = pygeoip.GeoIP(GEOIP_DB_PATH)


def set_geolocation(user):
    user_ip = request.headers.get('X-Forwarded-For')
    if user_ip:
        try:
            record = gi.record_by_addr(user_ip)
        except pygeoip.GeoIPError:
            return
        country_code = record.get('country_code')
        city = unicode(record.get('city', ''), 'iso-8859-1')
        if user.location_country != country_code or user.location_city != city:
            user.location_country = country_code
            user.location_city = city
            meta.Session.commit()

