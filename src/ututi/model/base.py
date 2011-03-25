from sqlalchemy.orm.exc import NoResultFound

from ututi.model import meta

class Model(object):
    """Abstract model object that provides general helper methods."""

    @classmethod
    def get(cls, id):
        try:
            return meta.Session.query(cls).filter_by(id=id).one()
        except NoResultFound:
            return None

    @classmethod
    def all(cls):
        return meta.Session.query(cls).all()

    def delete(self):
        meta.Session.delete(self)
