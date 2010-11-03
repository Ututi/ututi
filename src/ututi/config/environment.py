"""Pylons environment configuration"""
import os
import tempfile

from paste.util.converters import asbool
from mako.lookup import TemplateLookup
from pylons.error import handle_mako_error
from pylons.configuration import PylonsConfig
from sqlalchemy import engine_from_config

import ututi.lib.app_globals as app_globals
import ututi.lib.helpers
from ututi.config.routing import make_map
from ututi.model import init_model


class FixedPylonsConfig(PylonsConfig):

    def __getattr__(self, name):
        try:
            return PylonsConfig.__getattr__(self, name)
        except KeyError:
            raise AttributeError


def load_environment(global_conf, app_conf):
    """Configure the Pylons environment via the ``pylons.config``
    object
    """
    config = FixedPylonsConfig()

    pgport = os.environ.get("PGPORT", "4455")
    os.environ["PGPORT"] = pgport

    # Pylons paths
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    paths = dict(root=root,
                 controllers=os.path.join(root, 'controllers'),
                 static_files=os.path.join(root, 'public'),
                 templates=[os.path.join(root, 'templates')])

    # Initialize config with the basic options
    config.init_app(global_conf, app_conf, package='ututi', paths=paths)

    config['routes.map'] = make_map(config)
    config['pylons.app_globals'] = app_globals.Globals(config)
    config['pylons.h'] = ututi.lib.helpers

    # Create the Mako TemplateLookup, with the default auto-escaping
    config['pylons.app_globals'].mako_lookup = TemplateLookup(
        directories=paths['templates'],
        error_handler=handle_mako_error,
        module_directory=os.path.join(app_conf['cache_dir'], 'templates'),
        input_encoding='utf-8', default_filters=['escape'],
        imports=['from webhelpers.html import escape'])

    # Setup the SQLAlchemy database engine
    engine = engine_from_config(config, 'sqlalchemy.',
                                encoding='utf-8')
    init_model(engine)

    # CONFIGURATION OPTIONS HERE (note: all config options will override
    # any Pylons config options)
    if asbool(config.get('reset_database', 'false')):
        config['files_path'] = tempfile.mkdtemp(prefix="uploads_")

    return config
