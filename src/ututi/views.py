"""
Simple Views for pylons.

Usage examples
--------------

Inherit from base view class

    >>> class View(ViewBase):
    ...     grokcore.component.context(Event)
    ...     grokcore.component.implements(IView)
    ...     grokcore.component.name('render')
    ...
    ...     def __call__(self):
    ...         return render_mako_def('foo.mako', 'some_def', event=self.context)

Decorator on a function:

    >>> @view(Event, name='render')
    ... def default_event_render(event):
    ...     return 'HOI'

    >>> @view(GroupCreatedEvent, name='render')
    ... def render_group_created_event(event):
    ...     return 'HAI'

    >>> @view(PageModifiedEvent, name='render')
    ... def page_modified_view(event):
    ...     return 'HOIOIOI'

To use it do:

    >>> render_view(context, name='render')

or just:

    ${v(context, 'render')} in mako templates.

"""
from webhelpers.html.builder import literal

from zope.component import getAdapter
from zope.interface import Interface

import grokcore.component


class IView(Interface):

    def __call__(self):
        """Render the view."""


def render_view(context, name):
    return literal(getAdapter(context, IView, name=name).__call__())


class ViewBase(grokcore.component.Adapter):
    grokcore.component.context(Interface)
    grokcore.component.implements(IView)

    def __init__(self, context):
        self.context = context


def view(context, name):
    def make_view(method):
        class View(ViewBase):
            grokcore.component.context(context)
            grokcore.component.implements(IView)
            grokcore.component.name(name)

            def __call__(self):
                return method(self.context)
        return View
    return make_view
