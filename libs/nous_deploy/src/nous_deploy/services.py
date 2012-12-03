import sys
import pkg_resources

from contextlib import contextmanager
from functools import wraps

from fabric.utils import _AttributeDict
from fabric.state import env
from fabric import network


@contextmanager
def host_string(new_host_string):
    try:
        old_host_string = env.host_string
        env.host_string = new_host_string
        yield
    finally:
        env.host_string = old_host_string


def run_as(user):
    def decorator(func):
        @wraps(func)
        def inner(self, *args, **kwargs):
            old_user, host, port = network.normalize(env.host_string)
            if not host:
                host, port = self.server.host, self.server.port
            env.service = self
            env.server = self.server
            with host_string(network.join_host_strings(user, host, port)):
                return func(self, *args, **kwargs)
        inner._is_a_command = True
        return inner
    return decorator


def run_as_user(func):
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        return run_as(self.user)(func)(self, *args, **kwargs)
    wrapper._is_a_command = True
    return wrapper


def run_as_sudo(func):
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        return run_as(self.server.SUDO_USER)(func)(self, *args, **kwargs)
    wrapper._is_a_command = True
    return wrapper


class Service(object):

    default_settings = {}

    def propagate_settings(self):
        for _ in range(len(self.settings)):
            for key, value in self.settings.items():
                if isinstance(value, basestring):
                    new_value = value.format(**self.settings)
                    self.settings[key] = new_value
        self.settings = _AttributeDict(self.settings)

    def __init__(self, name, user, settings=None):
        self.collect_actions()
        self.name = name
        self.user = user

        self.settings = dict(self.default_settings)
        self.settings['name'] = name
        self.settings['user'] = user

        settings = settings if settings is not None else {}
        self.settings.update(settings)

        self.propagate_settings()

        self.server = None

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

    def bind(self, server):
        self.server = server
        return self

    @property
    def title(self):
        if self.server:
            return "{host}_{service}".format(host=self.server.title, service=self.name)
        return self.name

    def upload_config_template(self, name, to, context, **kwargs):
        template_dir = pkg_resources.resource_filename(self.__class__.__module__, 'config_templates')
        self.server.upload_config_template(name, to, context, template_dir=template_dir,
                                           **kwargs)

    # API

    def prepare(self):
        pass

    def setup(self):
        pass

    def configure(self):
        pass

    def remove(self):
        pass


def init(servers):
    scope = {}
    for server in servers:
        for command_name, cmd in server.commands.items():
            command_name = '{server}_{command}'.format(server=server.title,
                                                       command=command_name)
            scope[command_name] = cmd
        for service in server.services:
            for command_name, cmd in service.commands.items():
                command_name = '{service}_{command}'.format(service=service.title,
                                                            command=command_name)
                scope[command_name] = cmd
    return scope
