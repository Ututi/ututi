from setuptools import setup, find_packages

setup(
    name='ututi',
    version='0.1',
    description='',
    author='',
    author_email='',
    url='',
    install_requires=[
        "Pylons",
        "SQLAlchemy",
        "z3c.testsetup",
        "repoze.what-pylons",
        "psycopg2",
        "FormEncode",
        "wsgi_intercept",
        "zope.testbrowser",
        "zope.cachedescriptors",
        "lxml",
        "nous.mailpost",
        "python_magic",
        "Pillow",
        "Babel",
        "translitcodec",
        "trans",
        "python-openid",
        "nous.pylons.grok",
        "nous.pylons.testing",
        "nous.pylons.geoip",
        "addhrefs",
    ],
    package_dir={'': 'src'},
    packages=find_packages('src'),
    include_package_data=True,
    package_data={'ututi': ['i18n/*/LC_MESSAGES/*.mo']},
    message_extractors={'src/ututi': [
           ('**.py', 'python', None),
           ('templates/**.mako', 'mako', {'input_encoding': 'utf-8'}),
           ('public/**', 'ignore', None)]},
    zip_safe=False,
    paster_plugins=['PasteScript', 'Pylons'],
    entry_points="""
    [paste.app_factory]
    main = ututi.config.middleware:make_app

    [console_scripts]
    migrate = ututi.migration:main
    sms_daemon = ututi.lib.sms_daemon:main
    profile = cProfile:main

    [paste.app_install]
    main = pylons.util:PylonsInstaller
    """,
)
