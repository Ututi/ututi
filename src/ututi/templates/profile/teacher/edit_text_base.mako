<%inherit file="/profile/edit_base.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<%def name="css()">
  ${parent.css()}
  .text-form .cke_skin_kama {
    width: 100% !important;
    padding: 0;
  }
  .text-form .cke_contents {
    height: 500px !important;
  }
  .text-form .labelText {
    display: none;
  }
  p.warning {
    width: 50%;
  }
</%def>


<%def name="template_warning()">
%if getattr(c, 'edit_template', False):
<p class="tip warning">
${_("Below you see a template that you can freely edit. "
    "Note that once your press \"Save\", it will become "
    "publicly available in your profile page.")}
</p>
%endif
</%def>

${next.body()}
