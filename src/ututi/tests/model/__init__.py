#
from ututi.model import LocationTag
from ututi.model import meta


def setUpUser():
    #a user needs a university
    uni = LocationTag(u'U-niversity', u'uni', u'')
    meta.Session.add(uni)
    meta.Session.commit()

    #the user
    meta.Session.execute("insert into users (location_id, username, fullname, password)"
                         " (select tags.id, 'admin@uni.ututi.com', 'Administrator of the university', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7'"
                         " from tags where title_short = 'uni');")
    meta.Session.execute("insert into emails (id, email, confirmed)"
                         " (select users.id, users.username, true from users where fullname = 'Administrator of the university')")
    meta.Session.commit()

