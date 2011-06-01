from sqlalchemy import orm, Table
from sqlalchemy.orm import deferred

from ututi.model import meta
from ututi.model.base import Model
from ututi.model.util import logo_property


class Theme(Model):
    """Ututi theme."""

    header_logo = logo_property(logo_attr='raw_header_logo')


def setup_orm(engine):
    themes_table = Table("themes", meta.metadata,
                         autoload=True,
                         autoload_with=engine)

    orm.mapper(Theme, themes_table,
               properties = {'raw_header_logo': deferred(themes_table.c.header_logo)})
