from ututi.model import meta

def create_user(fullname='Administrator of the university',
                username='admin@uni.ututi.com',
                password='xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7',
                location_title='uni',
                second_mail=None):
    meta.Session.execute("insert into authors (type, fullname) values ('user', '%(fullname)s')" % dict(fullname=fullname))
    meta.Session.execute("insert into users (id, location_id, username, password)"
                         " (select authors.id, tags.id, '%(username)s', '%(password)s'"
                         " from tags, authors where title_short = '%(location_title)s' and fullname = '%(fullname)s' order by authors.id desc);" %
                         dict(username=username,
                              password=password,
                              location_title=location_title,
                              fullname=fullname))
    meta.Session.execute("insert into emails (id, email, confirmed)"
                         " (select users.id, users.username, true from users where username = '%(username)s')" %
                         dict(username=username))


    # Adding second email
    if second_mail:
        meta.Session.execute("insert into emails (id, email, confirmed)"
                             " (select users.id, '%(second_mail)s', true from users where username = '%(username)s')" %
                             dict(second_mail=second_mail, username=username))

    meta.Session.commit()
