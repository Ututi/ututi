import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
README = open(os.path.join(here, 'README.txt')).read()
CHANGES = open(os.path.join(here, 'CHANGES.txt')).read()

requires = [
    'fabric',
    'django-fab-deploy',
    'jinja2', # django-fab-deploy needs it
]

setup(name='nous_deploy',
      version='0.1',
      description='nous_deploy',
      long_description=README + '\n\n' +  CHANGES,
      classifiers=[
        "Programming Language :: Python",
        ],
      author='',
      author_email='',
      url='',
      keywords='web wsgi',
      package_dir={'': 'src'},
      packages=find_packages('src'),
      include_package_data=True,
      zip_safe=False,
      install_requires = requires,
      entry_points={},
      paster_plugins=['pyramid'],
      )
