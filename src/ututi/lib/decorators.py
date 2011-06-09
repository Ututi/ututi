import logging
import simplejson
from pylons.decorators.util import get_pylons

log = logging.getLogger(__name__)

def jsonpify(prefix='eval'):
    """Return method output as JSON padded with a given prefix.
    See http://en.wikipedia.org/wiki/JSONP for information about JSONP.
    """
    def jsonpify_decorator(func):
        def _jsonpify(*args, **kwargs):
            pylons = get_pylons(args)
            pylons.response.headers['Content-Type'] = 'application/json'
            data = func(*args, **kwargs)
            log.debug("Returning JSONP wrapped action output")
            return prefix + '(' + simplejson.dumps(data) + ')'

        return _jsonpify

    return jsonpify_decorator
