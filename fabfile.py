from nous_deploy import services
from nous_deploy import ubuntu
from nous_deploy import vututi
from nous_deploy import psql
from nous_deploy import sentry

ignas = ('ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEA1k5A4ViR29O3XEride/ZIO52LNwEPVyTh'
         'v8Rk9pweyMrlPoyg43TG+slndvy4Vju73tnd1fGWDrmAast9WVLm5Pd5GaWCtP4WU8I24'
         'nsohf7Gz0bo84SMp7ROFAmcnPuq2j5/39KZzbDW810fVCpxD5+qsDTusTcCA4yrROxjUU'
         '= ignas@pow.lt')
frgtn = ('ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgByG8k8a7n2mTWPr9q19KgzZArLBlinp0EXc'
         'uQApWl0xB12i6zGU8x9vuKtLwInXWFDVOS5H2GvTPAfd0KXIXT82QsLMcpe7ihwClXE1X'
         'sAwKY5x3VFvMNuTuvLDE3NUCt6RgHdW/nTOuINUrS4iiSUe+zR/olQfBBip+4UnfFXdGa'
         'H4d+bDMUSp7ivdEntx3bpbxgzVFSKz9KkBesyoFXz38J3Vfn980TlLSllfzlF1c9jF+Iw'
         'PjzVJVegeSTLBBGGFoJw7PZnoOSu8I+OtuSyW/Z90wU+hFnLdaUswhtmC5JlWZYH037ME'
         'DTzNziQOrETlB09hwduU46noR/z+TgaKioXcIPNE3gZs+FcIZhryc1abMcEeUvEzCl+ZS'
         '64sQLPsRQ4N8+5suSGim2TAZs8XvQWqewB5PPuJ8LpyXiWlcSh+DFb7DLUQyF97HH9Dm+'
         'BUKbUeTg2nljh02Vt7TCWsaxnxvukWpzrxfNIuOfu6r/LMsiF7rgUwwgVuqCzM7QuY3gb'
         'I/HLN9BpUaHxwaWJ1L44Wyni0GAisGDVdOZeNL6FD4QovoOwZMJujajEoeUXh2JDkw4mq'
         'HgQ3XpB9zMwMK4uTmgxEgYgLr338vPhbwOZ2kV9wrpvWsvtpt+Trkuz/lKomdry7BdP5E'
         'D6Od58Wsw4WZ4qFCp1HOrQf0ZMSw== frgtn@thkp')
hudson = ('ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzWhG/uSVbhrZ9NP9mTQiSJLp1O3uEEbX'
          'fb3Vu24Sz7TyU5GOHDYogv97H4HFqvczEVw9O0luFER29PjbI+mVe1TKnXG2Caz8OJoj'
          'cU1pYdluskYJcwNhFFOdVR7lTdw/SFidJycoDje1xc3qHjN2yUO8crH60Xob/7dY2Vbh'
          'OSP6UxvDusNsHHII94jIrro4UEHjQrwH8Jx4aVBlAURLhVvkjgeVvrVJxnVgNnUK4QgW'
          'LPRYTKzfr/gOGfhqR5fTchtKedNdApiHQKwP6vjH1J5+VeX3EZUuIl3PCB+9h2hNYXs7'
          'KY0NmzqgjsH4sNgAk6i+Vz4Rp+N6VmB2LO53tQ== hudson@bmw')

sentry_dsn = {'public': '73d402a014734bbc9ea4a63737eea6b7',
              'private': 'b3f9d14ddcca4609a47d55b050fb80e7'}


servers = [ubuntu.Server(host='klevas.mif.vu.lt',
                         port='22126',
                         name='vututi',
                         settings={'identities': [('', ignas),
                                                  ('', frgtn),
                                                  ('vututi', hudson)]},
                         services=[psql.Postgresql(name='ututi_db',
                                                   user='vututi',
                                                   settings={'port': 57861,
                                                             'extra_options': ["custom_variable_classes='ututi'",
                                                                               "ututi.active_user=0",
                                                                               "default_text_search_config='public.lt'"],
                                                             'password': 'duarkliukaivarshkepienas',
                                                             'version': '8.4'}),
                                   vututi.VUtuti(name='vututi',
                                                 user='vututi',
                                                 settings={'srv': '/mnt/vututidisk',
                                                           'upload_dir': '/mif/projects3/vututi/uploads',
                                                           'backups_dir': '/mif/projects3/vututi/backups',
                                                           'email_to': 'errors@ututi.lt',
                                                           'error_email_from': 'release@{host_name}',
                                                           'error_email': 'errors@ututi.lt',
                                                           'ututi_email_from': 'info@{host_name}',
                                                           'database': 'ututi_db',
                                                           'port': 57862,
                                                           'host_name': 'mif.u2ti.com',
                                                           'groups_host_name': 'groups.mif.u2ti.com'}),
                                   # sentry.Sentry(name='sentry',
                                   #               user='sentry',
                                   #               settings={'host_name': 'sentry.mif.u2ti.com',
                                   #                         'port': 19000,
                                   #                         'admin_username': 'admin',
                                   #                         'admin_email': 'saulius@nous.lt',
                                   #                         'admin_password': 'medausstatinaite',
                                   #                         'project_name': 'vututi',
                                   #                         'dsn_public': sentry_dsn['public'],
                                   #                         'dsn_secret': sentry_dsn['private']})
                                   ])]

globals().update(services.init(servers))
