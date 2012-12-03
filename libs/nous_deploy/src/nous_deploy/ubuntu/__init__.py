import os
import sys
import pkg_resources

from functools import wraps
from fabric.operations import sudo
from fabric.operations import run
from fabric.context_managers import settings
from fabric.context_managers import cd
from fabric.contrib.files import append
from fabric.contrib.files import exists
from fabric.contrib.files import upload_template
from fabric.state import env
from fabric import network

from nous_deploy.services import host_string


def run_as(user):
    def decorator(func):
        @wraps(func)
        def inner(self, *args, **kwargs):
            env.server = self
            with host_string(network.join_host_strings(user, self.host, self.port)):
                return func(self, *args, **kwargs)
        inner._is_a_command = True
        return inner
    return decorator


def run_as_sudo(func):
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        env.server = self
        return run_as(self.SUDO_USER)(func)(self, *args, **kwargs)
    wrapper._is_a_command = True
    return wrapper


class Server(object):

    SUDO_USER = 'root'
    port = 22

    def __init__(self, host, name, services, port=None, settings=None):
        self.collect_actions()
        self.host = host
        if port is not None:
            self.port = port
        self.name = self.title = name
        self.services = [service.bind(self) for service in services]
        self.settings = settings if settings is not None else {}

    def collect_actions_from_class(self, cls):
        return [k for k, v in cls.__dict__.items()
                if hasattr(v, '_is_a_command')]

    def collect_actions(self):
        actions = set()
        for cls in reversed(self.__class__.__mro__):
            actions.update(self.collect_actions_from_class(cls))
        self._commands = [action
                          for action in list(actions)
                          if not action.startswith('_')]

    @property
    def commands(self):
        return dict([(cmd, getattr(self, cmd))
                     for cmd in self._commands])

    @run_as_sudo
    def apt_get_update(self, force=False):
        if not hasattr(env, '_APT_UPDATED') or force:
            run('apt-get update')
            env._APT_UPDATED = True

    @run_as_sudo
    def getHomeDir(self, username):
        return run("echo ~%s" % username).strip()

    @run_as_sudo
    def ssh_update_identities(self, username):
        home_dir = self.getHomeDir(username)
        with cd(home_dir):
            sudo('mkdir -p .ssh')
            identities = [ssh_key
                          for user, ssh_key in self.settings['identities']
                          if not user or user == username]
            append('.ssh/authorized_keys', identities, use_sudo=True)
            sudo('chown -R %s:%s .ssh' % (username, username))

    @run_as_sudo
    def ensure_user(self, username):
        username = username
        with settings(warn_only=True):
            result = run("id %s" % username)
        if not result.succeeded:
            run('adduser %s --disabled-password --gecos ""' % username)
            self.ssh_update_identities(username)

    @run_as_sudo
    def apt_get_install(self, packages, options=''):
        """Installs package via apt get."""
        self.apt_get_update()
        run('apt-get install %s -y %s' % (options, packages,))

    def upload_config_template(self, name, to, context, template_dir=None,
                               **kwargs):
        if template_dir is None:
            template_dir = pkg_resources.resource_filename('nous_deploy.ubuntu', 'config_templates')
        self._upload_config_template(name, to, context, template_dir=template_dir,
                                     **kwargs)

    def _upload_config_template(self, name, to, context, template_dir,
                               use_jinja=True, backup=False, **kwargs):
        upload_template(name, to, context,
                        template_dir=template_dir,
                        use_jinja=use_jinja,
                        backup=backup,
                        **kwargs)

    @run_as_sudo
    def compile_locales(self):
        run("locale-gen en_US.UTF-8")

    @run_as_sudo
    def apache_remove(self):
        run('apt-get remove -y apache2 apache2.2-common apache2.2-bin apache2-utils')

    @run_as_sudo
    def nginx_install(self):
        self.apt_get_install("nginx")
        run('rm -f /etc/nginx/sites-enabled/default')

    def getService(self, service_name):
        service_obj = service_name
        if isinstance(service_name, basestring):
            for service in self.services:
                if service.name == service_name:
                    service_obj = service
                    break
        return service_obj

    @run_as_sudo
    def nginx_configure_site(self, service):
        service = self.getService(service)
        self.upload_config_template('nginx_proxy_settings.config',
                                    '/etc/nginx/nginx_proxy_settings.config', {})
        self.upload_config_template('nginx.config',
                                    '/etc/nginx/sites-available/%s' % service.name,
                                    {'service': service,
                                     'server': self},
                                    use_sudo=True)
        with settings(warn_only=True):
            run('ln -s /etc/nginx/sites-available/%s /etc/nginx/sites-enabled/%s' % (service.name, service.name))
        run('/etc/init.d/nginx restart')

    @run_as_sudo
    def nginx_remove_site(self, service):
        service = self.getService(service)
        run('rm -f /etc/nginx/sites-available/%s' % service.name)
        run('rm -f /etc/nginx/sites-enabled/%s' % service.name)
        run('/etc/init.d/nginx restart')

    @run_as_sudo
    def prepare(self):
        """Sets up all the dependencies"""
        self.compile_locales()
        self.apache_remove()
        self.nginx_install()
        for service in self.services:
            service.prepare()

    @run_as_sudo
    def setup(self):
        """Installs and sets up all the services themselves."""
        for service in self.services:
            service.setup()

    @run_as_sudo
    def configure(self):
        """Updates configuration for all the services."""
        for service in self.services:
            service.configure()

    @run_as_sudo
    def remove(self):
        """Stops and removes all the services."""
        for service in self.services:
            service.remove()

    @run_as_sudo
    def ensure_shm(self):
        # XXX check if file exists
        self.upload_config_template('S56mountshm.sh', '/etc/rcS.d/S56mounshm.sh', {},
                                    use_sudo=True)
        run("chmod +x /etc/rcS.d/S56mounshm.sh")
        run("/etc/rcS.d/S56mounshm.sh")
