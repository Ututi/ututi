<%inherit file="/ubase-two-sidebars.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>


<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
  ${user_sidebar()}
</%def>

<%def name="portlets_right()">
${group_right_sidebar()}
</%def>

<%def name="css()">
   ${parent.css()}

   #group-information {
      margin-top: 15px;
      min-height: 80px;
   }

   #group-information .group-logo {
      float: left;
      margin-right: 15px;
   }

   #group-information .group-title {
      margin-bottom: 7px;
   }

   #group-information .group-title a {
      font-size: 14px;
      font-weight: bold;
      line-height: 0.5;
   }

</%def>

<%def name="group_menu(show_title=True)">
%if show_title:

  <h1 class="page-title">
    ${self.title()}
  </h1>
  %if not c.group.is_member(c.user):
  <div style="float: right;">
    ${h.button_to(_('become a member'), url(controller='group', action='request_join', id=c.group.group_id))}
  </div>
  %endif

  <div id="group-information">
    <div class="group-logo">
      <img id="group-logo" src="${url(controller='group', action='logo', id=c.group.group_id, width=70, height=70)}" alt="logo" />
    </div>

    <div class="group-title" class="break-word">
      <a href="${url(controller='group', action='home', id=c.group.group_id)}">${self.title()}</a>
    </div>

    %if c.user is not None:
    <div class="break-word">
      %if c.group.is_member(c.user):
      <a href="${url(controller='mailinglist', action='new_thread', id=c.group.group_id)}" title="${_('Mailing list address')}">${c.group.group_id}@${c.mailing_list_host}</a>
      %elif c.group.mailinglist_moderated:
      <a href="${url(controller='mailinglist', action='new_anonymous_post', id=c.group.group_id)}" title="${_('Mailing list address')}">${c.group.group_id}@${c.mailing_list_host}</a>
      %endif
    </div>
    %endif

    <div class="break-word">
      %if c.group.location:
      <a href="${c.group.location.url()}">${' | '.join(c.group.location.title_path)}</a>
      %endif
    </div>


    <div class="break-word">
      %if c.group.description:
      ${c.group.description}
      %endif
    </div>

    <div class="break-word">
      %if c.group.is_admin(c.user) or c.security_context and h.check_crowds(['admin', 'moderator']):
      <a href="${url(controller='group', action='edit', id=c.group.group_id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
      %endif
    </div>
  </div>

%endif

%if c.group.is_member(c.user) or c.security_context and h.check_crowds(['admin', 'moderator']):
<ul class="tabs" id="tabs">
    %for menu_item in c.group_menu_items:
      <li class="${'current' if menu_item['name'] == getattr(c, 'group_menu_current_item', None) else ''}">
        <a href="${menu_item['link']}">${menu_item['title']}
            <span class="edge"></span>
        </a></li>
    %endfor
</ul>
%endif
</%def>

${self.group_menu()}

${next.body()}

%if request.GET.get('paid_sms'):
  <div id="got-sms-dialog" style="display: none">
      <div style="font-size: 14px; color: #666; font-weight: bold"
          >${_("Congratulations! You have purchased %s personal SMS credits.") % request.GET.get('paid_sms')}</div>

      <div>
        ${_("You can use these credits to send %s messages. For example, if your group has 20 members with registered phone numbers, one message will cost 20 SMS credits.") % request.GET.get('paid_sms')}
      </div>

      <div style="padding-left: 120px">
        ${h.image('/images/happy_cat.png', alt=_('Happy cat'))}
      </div>
  </div>

  <script>
    $(document).ready(function() {
        var dlg = $('#got-sms-dialog').dialog({
            title: '${_('Thanks!')}',
            width: 500
        });
        dlg.dialog("open");
        return false;
    });
  </script>
%endif

%if request.GET.get('paid_space'):
  <div id="got-space-dialog" style="display: none">
      <div style="font-size: 14px; color: #666; font-weight: bold"
          >${_("Congratulations! You have increased the group's private file limit.")}</div>

      <div style="padding-top: 1em; padding-bottom: 1em">
        ${_("You can now store up to %(size)s in your group's private area. Time period extension: %(time)s.") % \
            dict(time=request.GET.get('paid_space'), size=h.file_size(int(c.pylons_config.get('paid_group_file_limit')))) |n}
        ${_('Have fun using Ututi groups!')}
      </div>

      <div style="padding-left: 120px">
        ${h.image('/images/happy_cat.png', alt=_('Happy cat'))}
      </div>
  </div>

  <script>
    $(document).ready(function() {
        var dlg = $('#got-space-dialog').dialog({
            title: '${_('Thanks!')}',
            width: 500
        });
        dlg.dialog("open");
        return false;
    });
  </script>
%endif

%if request.GET.get('cancelled_space_payment'):
    <div id="cancelled-space-dialog" style="display: none">
      <div style="font-size: 14px; color: #666; font-weight: bold"
        >${_("You have decided not to increase your group's private file limit.")}</div>

      <div style="padding-top: 1em; padding-bottom: 1em">
        ${_('Perhaps you will change your mind later?')}
        ${_('Have fun using Ututi groups!')}
      </div>

      <div style="padding-left: 120px">
        ${h.image('/images/sad_cat.jpg', alt=_('Sad cat'))}
      </div>
  </div>

  <script>
    $(document).ready(function() {
        var dlg = $('#cancelled-space-dialog').dialog({
            title: '${_('Thanks!')}',
            width: 500
        });
        dlg.dialog("open");
        return false;
    });
  </script>
%endif

%if request.GET.get('cancelled_sms_payment'):
    <div id="cancelled-sms-dialog" style="display: none">
      <div style="font-size: 14px; color: #666; font-weight: bold"
        >${_("You have decided not to buy extra SMS credits.")}</div>

      <div style="padding-top: 1em; padding-bottom: 1em">
        ${_('Perhaps you will change your mind later?')}
        ${_('Have fun using Ututi groups!')}
      </div>

      <div style="padding-left: 120px">
        ${h.image('/images/sad_cat.jpg', alt=_('Sad cat'))}
      </div>
  </div>

  <script>
    $(document).ready(function() {
        var dlg = $('#cancelled-sms-dialog').dialog({
            title: '${_('Thanks!')}',
            width: 500
        });
        dlg.dialog("open");
        return false;
    });
  </script>
%endif
