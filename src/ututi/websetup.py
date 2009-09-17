"""Setup the ututi application"""
import logging

from paste.util.converters import asbool
from ututi.model import initialize_db_defaults, reset_db
from ututi.config.environment import load_environment
from ututi.model import meta

log = logging.getLogger(__name__)

def setup_app(command, conf, vars):
    """Place any commands to setup ututi here"""
    load_environment(conf.global_conf, conf.local_conf)

    if asbool(conf.get('reset_database', 'false')):
        reset_db(meta.engine)
    initialize_db_defaults(meta.engine)
