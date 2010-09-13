import os
import pygeoip
import ututi

from pylons import request

GEOIP_DB_PATH = os.path.join(ututi.__path__[0], '..', 'GeoIPCity.dat')
gi = pygeoip.GeoIP(GEOIP_DB_PATH)


def set_geolocation(user):
    user_ip = request.headers.get('X-Forwarded-For')
    if user_ip:
        record = gi.record_by_addr(user_ip)
        if (user.location_country != record['country_code']
            or user.location_city != record['city']):
            user.location_country = record['country_code']
            user.location_city = record['city']
            meta.Session.commit()

