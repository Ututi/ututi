<%inherit file="/profile/base.mako" />
<%namespace name="b" file="/prebase.mako" import="rounded_block"/>
<%namespace file="/sections/content_snippets.mako" import="tooltip" />
<%namespace name="dashboard" file="/sections/wall_dashboard.mako" />

<%def name="body_class()">wall</%def>

<%def name="pagetitle()">
  ${_("What's new?")}
</%def>

<%def name="head_tags()">
    ${dashboard.head_tags()}
    ${h.javascript_link('/javascript/wall.js')}
    ${h.javascript_link('/javascript/jquery.jtruncate.pack.js')}
    ${h.stylesheet_link('/widgets.css')}
    <script type="text/javascript">
    $(document).ready(function() {
        /* Truncate texts. */
        $('span.truncated').jTruncate({
            length: 150,
            minTrail: 50,
            moreText: "${_('more')}",
            lessText: "${_('less')}",
            moreAni: 300
            ## leave lessAni empty, to avoid jQuery show/hide quirks!
            ## (after first hide it would the show element as inline-block,
            ##  (instead of inline) affeting layout)
        });
    });
    </script>
</%def>

<a id="settings-link" href="${url(controller='profile', action='wall_settings')}">${_('Wall settings')}</a>

${dashboard.dashboard(None, c.file_recipients, c.wiki_recipients)}

%for event in c.events:
  ${event.wall_entry()}
%endfor
