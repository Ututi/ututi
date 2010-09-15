<%inherit file="/portlets/base.mako"/>

<%def name="facebook_likebox_portlet()">
  %if c.lang in ['lt', 'en']:
    <fb:like-box href="http://www.facebook.com/ututi" width="300" header="false"></fb:like-box>
  %else:
    <fb:like-box href="http://www.facebook.com/ututipl" width="300" header="false"></fb:like-box>
  %endif
</%def>
