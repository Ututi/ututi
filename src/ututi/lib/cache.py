from pylons.decorators.cache import beaker_cache

def u_cache(**kwargs):
    kwargs['cache_response'] = False
    return beaker_cache(**kwargs)
