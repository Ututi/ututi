#
from datetime import date
from ututi.model.users import User
from ututi.model import Group
from ututi.model import LocationTag
from ututi.model import meta


def setUpUser():
    #a user needs a university
    uni = LocationTag(u'U-niversity', u'uni', u'', member_policy='PUBLIC')
    meta.Session.add(uni)
    meta.Session.commit()

    #the user
    meta.Session.execute("insert into authors (type, fullname) values ('user', 'Administrator of the university')")
    meta.Session.execute("insert into users (id, location_id, username, password)"
                         " (select authors.id, tags.id, 'admin@uni.ututi.com', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7'"
                         " from tags, authors where title_short = 'uni' and fullname = 'Administrator of the university');")
    meta.Session.execute("insert into emails (id, email, confirmed)"
                         " (select users.id, users.username, true from users where username = 'admin@uni.ututi.com')")
    meta.Session.commit()


def setUpModeratorGroup():

    u = User.get('admin@uni.ututi.com', LocationTag.get(u'uni'))
    meta.set_active_user(u.id)

    g = Group('moderators', u'Moderatoriai', LocationTag.get(u'uni'), date.today(), u'U2ti moderatoriai.')
    g.moderators = True
    g.add_member(u, True)
    meta.Session.add(g)
    meta.Session.commit()

    meta.set_active_user(u.id)
