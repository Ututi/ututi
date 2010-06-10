<%inherit file="/group/base.mako" />
<%namespace file="/sections/content_snippets.mako" import="item_tags, tag_link, item_location"/>

<%def name="head_tags()">
<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){
  function unselectSubject(event) {
    var url = $(event.target).parent().prev('.remove_url').val();
    $.ajax({type: "GET",
            url: url,
            success: function(msg){
                $(event.target).closest('.snippet-subject').remove();
                if ($('#SearchResults').children().size() == 1) {
                  $('#empty_subjects_msg').toggleClass('hidden');
                }

    }});
    return false;
  }

  $('.remove_subject_button').click(unselectSubject);

});
//]]>
</script>

${parent.head_tags()}

</%def>


<%def name="subjects_block(title, subjects)">
<%self:rounded_block class_='portletGroupFiles subject_description'>
  <div class="GroupFiles GroupFilesDalykai">
    <h2 class="portletTitle bold">
      ${title|n}
    </h2>
    <div class="group-but" style="top: 10px;">
      ${h.button_to(_('add a subject'), c.group.url(action='subjects_watch'))}
    </div>
  </div>
  <div id="SearchResults">
    %if subjects:
      ${subject_list(subjects)}
    %endif
    <span class="empty_note" id="empty_subjects_msg"${'style="display: none;"' if subjects else ''|n}>
      ${_('No watched subjects were found.')}
    </span>

  </div>
</%self:rounded_block>
</%def>

<%def name="subject_item(object, last=False)">
  <div class="search-item snippet-subject${' last' if last else ''}">
    <div style="float: right; margin-right: 15px;">
      <input type="hidden" class="remove_url"
             value="${c.group.url(action='js_unwatch_subject', subject_id=object.subject_id, subject_location_id=object.location.id)}" />
      <a href="${c.group.url(action='unwatch_subject', subject_id=object.subject_id, subject_location_id=object.location.id)}" class="remove_subject_button">
        ${h.image('/img/icons/cross_big.png', alt='unwatch')|n}
      </a>
    </div>

    <a href="${object.url()}" title="${object.title}" class="item-title bold larger">${object.title}</a>
    <span class="verysmall">(${_('Subject rating:')} </span><span>${h.image('/images/details/stars%d.png' % object.rating(), alt='', class_='subject_rating')|n})</span>
    <div class="description">
      ${item_location(object)}
      % if object.lecturer:
       | ${object.lecturer}
      % endif
      %if object.tags:
       | ${item_tags(object)}
      %endif
    </div>
    <dl class="stats">
       <%
           file_cnt = len(object.files)
           page_cnt = len(object.pages)
           group_cnt = object.group_count()
           user_cnt = object.user_count()
        %>

        <dd class="files">${ungettext('%(count)s <span class="a11y">file</span>', '%(count)s <span class="a11y">files</span>', file_cnt) % dict(count = file_cnt)|n}</dd>
        <dd class="pages">${ungettext('%(count)s <span class="a11y">wiki page</span>', '%(count)s <span class="a11y">wiki pages</span>', page_cnt) % dict(count = page_cnt)|n}</dd>
        <dd class="watchedBy"><span class="a11y">${_('Watched by:')}</span> 
          ${ungettext("%(count)s group", "%(count)s groups", group_cnt) % dict(count = group_cnt)|n}
          ${_('and')}
          ${ungettext("%(count)s member", "%(count)s members", user_cnt) % dict(count = user_cnt)|n}
        </dd>
    </dl>
  </div>
</%def>

<%def name="subject_list(subjects)">
  <%
     count = len(subjects)
  %>
  %for n, subject in enumerate(subjects):
    ${subject_item(subject, n == count - 1)}
##  <div class="${'GroupFilesContent-line-dal' if n != count - 1 else 'GroupFilesContent-line-dal-last'}">
##    <ul class="grupes-links-list-dalykai">
##      <li>

##    	<dl>
##    	  <dt>
##            <span>
##              <a class="subject_title blark" href="${subject.url()}">${subject.title}</a>
##            </span>
##            <input type="hidden" class="remove_url"
##                   value="${url(controller='profile', action='js_unwatch_subject', subject_id=subject.id)}" />
##            <a href="${url(controller='profile', action='unwatch_subject', subject_id=subject.id)}" class="remove_subject_button">
##              ${h.image('/images/details/icon_cross_subjects.png', alt='unwatch')|n}
##            </a>
##          </dt>
## 		</dl>
##      </li>
##    </ul>
##    <br class="clear-left" />
##  </div>
  %endfor
</%def>

<div id="subject_settings">
  ${subjects_block(_('Subjects'), c.group.watched_subjects)}
</div>
