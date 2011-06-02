from sqlalchemy import orm, Table
from sqlalchemy.orm import deferred

from ututi.model import meta
from ututi.model.base import Model
from ututi.model.util import logo_property


class Theme(Model):
    """Ututi theme."""

    header_logo = logo_property(logo_attr='raw_header_logo')

    def clone(self):
        """Return a copy of this theme. No magic."""
        new_theme = self.__class__()
        new_theme.header_background = self.header_background
        new_theme.header_color = self.header_color
        new_theme.header_logo = self.header_logo
        return new_theme


def setup_orm(engine):
    themes_table = Table("themes", meta.metadata,
                         autoload=True,
                         autoload_with=engine)

    orm.mapper(Theme, themes_table,
               properties = {'raw_header_logo': deferred(themes_table.c.header_logo)})
