from pylons import request
from ututi.model import meta

from nous.pylons.geoip import get_city_and_country

def get_geolocation():
    user_ip = request.headers.get('X-Forwarded-For')
    if user_ip:
        country_code, city = get_city_and_country(user_ip)
        return country_code
    return None

def set_geolocation(user):
    user_ip = request.headers.get('X-Forwarded-For')
    if user_ip:
        country_code, city = get_city_and_country(user_ip)
        if not city:
            return
        if user.location_country != country_code or user.location_city != city:
            user.location_country = country_code
            user.location_city = city
            meta.Session.commit()
