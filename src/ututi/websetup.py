"""Setup the ututi application"""
import logging

from ututi.model import initialize_db_defaults
from ututi.config.environment import load_environment
from ututi.model import meta

log = logging.getLogger(__name__)

def setup_app(command, conf, vars):
    """Place any commands to setup ututi here"""
    load_environment(conf.global_conf, conf.local_conf)

    # Create the tables if they don't already exist
    initialize_db_defaults(meta.engine)
