from pylons import config
from pylons import tmpl_context as c
from pylons.i18n import _

from ututi.lib import helpers as h


class GroupPaymentInfo():
    """Stores functions for gruop payment information"""

    def group_file_limit(self):
        """Get group_file_limit"""
        return int(config.get('group_file_limit', 200 * 1024 * 1024))
