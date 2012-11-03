from sqlalchemy import orm, Table, Column
from sqlalchemy.orm import deferred

from pylons import url

from ututi.model import meta
from ututi.model.base import Model
from ututi.model.util import logo_property


class Theme(Model):
    """Ututi theme."""

    header_logo = logo_property(logo_attr='raw_header_logo')

    def has_logo(self):
        return self.header_logo is not None

    @property
    def logo(self):
        """This is a temporary workaround for prepare_logo to work.
        If you are reading this comment in 2013... Well... :D"""
        return self.header_logo

    def clone(self):
        """Return a copy of this theme. No magic."""
        new_theme = self.__class__()
        new_theme.header_background_color = self.header_background_color
        new_theme.header_color = self.header_color
        new_theme.header_logo = self.header_logo
        new_theme.header_text = self.header_text
        return new_theme

    def values(self):
        """Return a dict of values, for form filling etc."""
        return {
            'header_background_color': self.header_background_color,
            'header_color': self.header_color,
            'header_logo': self.header_logo,
            'header_text': self.header_text
        }

    def update(self, values):
        """Update values from dict, e.g. formr result."""
        self.header_text = values['header_text']
        self.header_background_color = values['header_background_color']
        self.header_color = values['header_color']

    def url(self, controller='theming', **kwargs):
        return url(controller=controller, id=self.id, **kwargs)


def setup_tables(engine):
    Table("themes", meta.metadata,
          autoload=True,
          useexisting=True,
          autoload_with=engine)


def setup_orm():
    tables = meta.metadata.tables
    orm.mapper(Theme, tables['themes'],
               properties = {'raw_header_logo': deferred(tables['themes'].c.header_logo)})
