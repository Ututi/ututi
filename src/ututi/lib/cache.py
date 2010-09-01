import random
from pylons.decorators.cache import beaker_cache


def u_cache(**kwargs):
    if 'expire' in kwargs:
        # Vary expiration times by +/- 20%.
        factor = 0.8 + (random.random() * 0.4)
        kwargs['expire'] = int(kwargs['expire'] * factor)
    kwargs['cache_response'] = False
    return beaker_cache(**kwargs)
