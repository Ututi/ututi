<%inherit file="/ubase-two-sidebars.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/elements.mako" import="tabs" />
<%namespace file="/portlets/sections.mako" import="user_sidebar, user_right_sidebar"/>
<%namespace file="/widgets/facebook.mako" import="init_facebook" />

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="portlets_right()">
${user_right_sidebar()}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
<%newlocationtag:head_tags />
</%def>

%if hasattr(self, 'pagetitle'):
  <h1 class="page-title with-bottom-line">${self.pagetitle()}</h1>
%endif

<%def name="group_feature_box()">
  <div class="feature-box one-column icon-group">
    <div class="title">
      ${_("About groups:")}
    </div>
    <div class="clearfix">
      <div class="feature icon-discussions">
        <strong>${_("Discussions")}</strong>
        - ${_("a place to discuss study matters and your student life.")}
      </div>
      <div class="feature icon-email">
        <strong>${_("E-mail")}</strong>
        - ${_("each group has an email address. If someone writes to this address, all groupmates will receive the email.")}
      </div>
      <div class="feature icon-file">
        <strong>${_("Private group files")}</strong>
        - ${_("private file storage area for files that you don't want to share with outsiders.")}
      </div>
      <div class="feature icon-notifications">
        <strong>${_("Subject notifications")}</strong>
        - ${_("receive notifications from subjects that your group is following.")}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Create a new group'), url(controller='group', action='create'), class_='add', method='GET')}
    </div>
  </div>
</%def>

<%def name="subject_feature_box()">
  <div class="feature-box one-column icon-subject">
    <div class="title">
      ${_("About subjects:")}
    </div>
    <div class="clearfix">
      <div class="feature icon-file">
        <strong>${_("A place for course material sharing")}</strong>
        - ${_("upload and share course material with students of your class, university or the entire world.")}
      </div>
      <div class="feature icon-discussions">
        <strong>${_("Discussions")}</strong>
        - ${_("a place to discuss subject related questions with students and teachers.")}
      </div>
    </div>
    <div class="clearfix">
      <div class="feature icon-wiki">
        <strong>${_("Shared notes")}</strong>
        - ${_("create wiki notes collaboratively with your class-mates or take notes during the lecture and upload it directly to Ututi.")}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Create a new subject'), url(controller='subject', action='add'), class_='add')}
    </div>
  </div>
</%def>

<%def name="homepage_nags_and_stuff()">
  %if c.fb_random_post:
  ${init_facebook()}
  <script type="text/javascript">
      //<![CDATA[
      $(document).ready(function() {
          FB.ui({
              method: 'stream.publish',
              message: '${c.fb_random_post}',
              attachment: {
                  name: 'Ututi - your university online',
                  description: (
                      '${_("Ututi is Your university online. "
                           "Here You and Your class mates can create your group online, "
                           "use the mailing list for communication and the file storage for sharing information.")}'
                  ),
                  href: '${url('/', qualified=True)}'
               },
               action_links: [ { text: 'Labas rytas', href: 'ututi.lt' } ],
               user_message_prompt: '${_('Share your thoughts about Ututi')}'
             },
             function(response) { }
         );
      });
      //]]>
  </script>
  %endif
</%def>


${next.body()}
