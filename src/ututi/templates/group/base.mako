<%inherit file="/ubase-sidebar.mako" />

<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
  ${group_sidebar()}
</%def>

<%def name="group_menu(show_title=True)">
%if show_title:
  <h1 class="pageTitle">
    ${self.title()}
    %if not c.group.is_member(c.user):
      <div style="float: right;">
        ${h.button_to(_('become a member'), url(controller='group', action='request_join', id=c.group.group_id))}
      </div>
    %endif
  </h1>
%endif

%if c.group.is_member(c.user) or c.security_context and h.check_crowds(['admin', 'moderator']):
<ul class="moduleMenu" id="moduleMenu">
    %for menu_item in c.group_menu_items:
      <li class="${'current' if menu_item['name'] == c.group_menu_current_item else ''}">
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
