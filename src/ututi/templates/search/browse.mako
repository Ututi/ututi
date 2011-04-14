<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/facebook.mako" import="*"/>
<%namespace file="/anonymous_index.mako" import="universities_section"/>
<%namespace file="/search/index.mako" import="search_form"/>

<%def name="location_tag(uni)">
<div class="university_block">
  %if uni['has_logo']:
    <div class="logo">
      <img src="${url(controller='structure', action='logo', id=uni['id'], width=26, height=26)}" alt="logo" />
    </div>
  %elif uni['parent_has_logo']:
    <div class="logo">
      <img src="${url(controller='structure', action='logo', id=uni['parent_id'], width=26, height=26)}" alt="logo" />
    </div>
  %endif

  <div class="title">
    <a href="${uni['url']}" title="${uni['title']}">${h.ellipsis(uni['title'], 36)}</a>
  </div>
  <div class="stats">
    <span>
      ${ungettext("%(count)s subject", "%(count)s subjects", uni['n_subjects']) % dict(count=uni['n_subjects'])|n}
    </span>
    <span>
      ${ungettext("%(count)s group", "%(count)s groups", uni['n_groups']) % dict(count=uni['n_groups'])|n}
    </span>
    <span>
      ${ungettext("%(count)s file", "%(count)s files", uni['n_files']) % dict(count=uni['n_files'])|n}
    </span>
  </div>
</div>
</%def>

<%def name="universities(unis, ajax_url)">
  %for uni in unis:
    ${location_tag(uni)}
  %endfor
  <div id="pager">
    ${unis.pager(format='~3~',
                 partial_param='js',
                 onclick="$('#pager').addClass('loading'); $('#university-list').load('%s'); return false;") }
  </div>
  <div id="sorting">
    ${_('Sort by:')}
    <%
       url_args_alpha = dict(sort='alpha')
       url_args_pop = dict(sort='popular')
       if request.params.get('region_id'):
               url_args_alpha['region_id'] = request.params.get('region_id')
               url_args_pop['region_id'] = request.params.get('region_id')
    %>
    <a id="sort-alpha" class="${c.sort == 'alpha' and 'active' or ''}" href="${url(ajax_url, **url_args_alpha)}">${_('name')}</a>
    <input type="hidden" id="sort-alpha-url" name="sort-alpha-url" value="${url(ajax_url, js=True, **url_args_alpha)}" />
    <a id="sort-popular" class="${c.sort == 'popular' and 'active' or ''}" href="${url(ajax_url, **url_args_pop)}">${_('popularity')}</a>
    <input type="hidden" id="sort-popular-url" name="sort-popular-url" value="${url(ajax_url, js=True, **url_args_pop)}" />
  </div>
</%def>

<%def name="universities_section(unis, ajax_url, collapse=True, collapse_text=None)">
  <%
     if collapse_text is None:
       collapse_text = _('More universities')
  %>
  %if unis:
  <div id="university-list" class="${c.teaser and 'collapsed_list' or ''}">
    ${universities(unis, ajax_url)}
  </div>
  %if collapse and len(unis) > 6:
    %if c.teaser:
      <div id="teaser_switch" style="display: none;">
            <span class="files_more">
              <a class="green verysmall">
                    ${collapse_text}
              </a>
            </span>
      </div>
    %endif
    <script type="text/javascript">
    //<![CDATA[
      $(document).ready(function() {
            $('#university-list.collapsed_list').data("preheight", $('#university-list.collapsed_list').height()).css('height', '115px');
            $('#teaser_switch').show();
            $('#teaser_switch a').click(function() {
              $('#teaser_switch').hide();
              $('#university-list').animate({
                    height: $('#university-list').data("preheight")},
                    200, "linear",
                    function() {
                      $('#university-list').css('height', 'auto');
                    });
              return false;
            });
      });
    //]]>
    </script>
  %endif
  <script type="text/javascript">
  //<![CDATA[
      $(document).ready(function() {
        $('#sort-alpha,#sort-popular').live("click", function() {
            var url = $('#'+$(this).attr('id')+'-url').val();
            $('#sorting').addClass('loading');
            $('#university-list').load(url);
            return false;
        });
      });
  //]]>
  </script>
  %endif
</%def>

<%def name="head_tags()">
  ${h.javascript_link('/javascript/jquery.maphilight.js')}

  <script type="text/javascript">
    $(document).ready(function() {
        $('img#region-map').maphilight({
            strokeColor: 'd45500',
            strokeWidth: 4,
            fillColor: 'd45500',
            fillOpacity: 0.4
        });
    });
  </script>
</%def>

<%def name="portlets()">
  ${facebook_likebox_portlet()}
</%def>

${search_form(c.text, c.obj_type, c.tags, parts=['text'], target=url(controller='search', action='index'))}

%if c.tpl_lang == 'pl' and 'region_id' not in request.params:
  <h2>${_('Pick your region')}</h2>

  ${h.image('/img/poland-regions.png', alt=_('Regions of Poland'), id='region-map', usemap='#map')}

  <map name="map">
    <area href="${url(controller='search', action='browse', region_id=1)}" title="Dolnośląskie" shape="poly" coords="70,248, 69,244, 67,240, 61,234, 60,232, 60,231, 60,230, 62,229, 64,227, 64,224, 64,222, 63,219, 60,218, 58,218, 57,219, 55,219, 52,219, 49,217, 47,215, 46,214, 44,214, 40,213, 35,210, 32,206, 31,202, 30,201, 29,201, 25,200, 22,199, 21,199, 20,201, 19,203, 19,206, 17,206, 15,206, 17,203, 20,197, 22,189, 24,185, 23,183, 23,181, 23,179, 25,177, 26,177, 27,178, 29,179, 31,179, 34,177, 35,175, 35,173, 36,173, 37,174, 39,177, 43,176, 45,173, 46,171, 47,170, 49,168, 49,166, 50,163, 51,163, 52,162, 52,161, 54,159, 57,158, 60,159, 61,162, 61,164, 63,165, 64,164, 66,161, 67,157, 71,161, 74,167, 76,169, 79,171, 83,174, 88,175, 92,175, 96,173, 99,171, 100,173, 101,175, 101,175, 100,178, 101,179, 104,181, 107,182, 108,185, 108,191, 108,192, 106,192, 103,193, 102,196, 101,198, 100,200, 96,206, 92,212, 90,219, 88,222, 87,223, 86,223, 85,225, 84,226, 83,228, 80,230, 79,232, 78,234, 78,235, 81,239, 83,242, 83,243, 81,244, 78,245, 75,247, 72,250, 70,248, 70,248" />
    <area href="${url(controller='search', action='browse', region_id=2)}" title="Kujawsko-pomorskie" shape="poly" coords="150,130, 149,130, 146,130, 141,129, 140,128, 139,126, 138,124, 135,124, 133,123, 132,122, 131,121, 128,120, 126,121, 126,122, 125,123, 124,123, 122,121, 118,119, 116,118, 115,116, 113,114, 112,113, 110,113, 108,114, 108,114, 107,113, 107,111, 105,111, 102,111, 100,110, 100,109, 102,107, 104,105, 104,102, 103,100, 100,97, 98,95, 97,91, 98,87, 100,85, 101,83, 102,81, 101,79, 100,77, 98,75, 98,74, 99,73, 100,72, 102,67, 104,63, 107,64, 110,64, 112,63, 113,61, 114,59, 117,59, 119,57, 121,56, 123,56, 125,57, 126,58, 128,59, 133,60, 138,61, 141,63, 144,65, 149,66, 154,66, 154,70, 155,72, 157,74, 165,79, 168,80, 168,83, 169,85, 170,86, 171,87, 170,87, 168,89, 167,91, 167,93, 168,94, 168,96, 165,97, 164,99, 163,100, 162,101, 161,102, 160,104, 160,106, 161,108, 162,110, 160,111, 159,114, 158,115, 157,116, 157,118, 158,123, 158,124, 157,125, 156,126, 155,128, 155,129, 154,130, 151,131, 150,130, 150,130" />
    <area href="${url(controller='search', action='browse', region_id=3)}" title="Lubelskie" shape="poly" coords="268,237, 262,236, 259,235, 257,234, 257,232, 260,230, 263,227, 263,225, 261,223, 259,222, 257,221, 255,221, 253,220, 252,218, 252,215, 252,211, 249,211, 245,212, 243,213, 241,211, 240,207, 239,201, 239,195, 240,188, 240,185, 239,178, 237,174, 236,172, 234,169, 234,169, 236,168, 238,168, 239,166, 240,164, 240,160, 241,156, 242,153, 241,150, 241,149, 243,149, 246,148, 251,147, 256,146, 259,145, 262,145, 262,144, 262,142, 263,142, 265,143, 267,143, 270,142, 274,138, 275,135, 277,134, 279,134, 282,135, 285,136, 289,138, 292,140, 292,147, 292,152, 292,154, 293,155, 292,157, 291,159, 291,163, 291,168, 293,170, 294,172, 295,177, 295,182, 297,185, 302,192, 305,198, 306,199, 308,203, 309,205, 308,207, 307,208, 307,209, 309,213, 311,218, 310,223, 308,227, 304,229, 300,231, 295,237, 294,238, 291,236, 288,234, 284,233, 281,234, 279,236, 277,238, 274,238, 268,237, 268,237" />
    <area href="${url(controller='search', action='browse', region_id=4)}" title="Lubuskie" shape="poly" coords="29,176, 25,176, 22,176, 22,175, 18,173, 14,171, 14,170, 14,168, 15,163, 14,161, 13,159, 10,156, 13,151, 15,148, 15,139, 14,132, 12,128, 11,124, 13,122, 14,117, 14,115, 13,113, 13,112, 13,111, 16,111, 17,110, 19,108, 21,104, 23,101, 25,99, 27,100, 29,100, 33,99, 38,95, 41,94, 43,93, 46,92, 51,91, 53,90, 54,88, 54,86, 55,86, 56,87, 56,90, 55,98, 52,101, 50,105, 48,109, 47,112, 48,114, 49,121, 49,125, 50,127, 51,128, 50,131, 50,138, 50,142, 53,145, 58,151, 59,152, 62,152, 64,153, 66,153, 66,155, 65,158, 63,161, 62,161, 62,159, 61,156, 59,156, 56,156, 52,159, 49,161, 48,164, 47,167, 46,168, 44,169, 43,171, 42,173, 41,174, 39,174, 38,172, 36,170, 34,171, 33,173, 32,176, 30,177, 29,176, 29,176" />
    <area href="${url(controller='search', action='browse', region_id=5)}" title="Łódzkie" shape="poly" coords="169,210, 168,208, 166,208, 164,207, 163,206, 162,204, 160,202, 158,201, 155,201, 151,201, 149,199, 147,198, 143,197, 137,198, 137,198, 135,197, 133,195, 131,195, 128,194, 125,193, 123,192, 121,190, 120,188, 120,186, 120,184, 121,182, 125,181, 127,181, 128,180, 129,171, 129,165, 130,162, 131,161, 134,160, 137,160, 140,158, 141,156, 141,153, 140,151, 140,149, 142,147, 143,147, 145,146, 146,144, 147,142, 148,140, 150,139, 150,138, 151,134, 154,132, 157,132, 160,134, 163,136, 168,136, 176,135, 178,135, 179,136, 180,140, 181,142, 183,143, 185,145, 186,148, 187,153, 193,154, 198,155, 199,155, 199,157, 201,161, 201,163, 200,164, 199,165, 196,165, 194,166, 192,167, 192,170, 194,172, 196,175, 197,178, 197,179, 196,179, 194,181, 192,184, 191,187, 189,189, 188,190, 187,191, 187,193, 183,193, 180,193, 179,194, 178,198, 180,199, 180,200, 181,201, 181,202, 180,203, 178,202, 177,201, 176,201, 174,204, 172,209, 170,211, 169,210, 169,210" />
    <area href="${url(controller='search', action='browse', region_id=6)}" title="Małopolskie" shape="poly" coords="182,299, 180,297, 176,298, 175,299, 176,298, 177,293, 176,289, 174,289, 171,288, 169,286, 167,284, 167,281, 166,280, 166,279, 164,277, 163,272, 161,270, 159,269, 157,267, 156,264, 156,261, 154,259, 152,257, 154,255, 159,249, 162,245, 162,243, 161,242, 160,242, 160,241, 162,239, 166,237, 169,236, 174,235, 176,233, 178,231, 182,231, 186,231, 188,231, 189,233, 189,236, 190,242, 193,246, 197,247, 202,246, 216,241, 218,244, 218,253, 219,257, 220,259, 220,260, 220,261, 219,262, 219,264, 219,266, 220,267, 222,269, 223,273, 225,281, 227,285, 221,286, 216,286, 216,286, 215,287, 215,290, 213,292, 210,292, 208,290, 206,288, 200,288, 194,288, 192,290, 189,292, 188,293, 186,296, 184,300, 182,299, 182,299" />
    <area href="${url(controller='search', action='browse', region_id=7)}" title="Mazowieckie" shape="poly" coords="225,199, 220,197, 218,196, 217,195, 215,193, 212,193, 209,194, 205,192, 202,189, 200,188, 199,187, 198,185, 197,184, 196,184, 195,183, 197,181, 198,180, 199,179, 199,177, 198,176, 197,174, 196,170, 195,169, 195,168, 198,167, 200,167, 202,166, 203,162, 203,160, 202,159, 201,156, 201,153, 195,153, 188,152, 187,147, 187,143, 185,142, 183,140, 182,138, 180,134, 179,133, 176,133, 169,134, 165,134, 161,132, 157,129, 157,127, 159,126, 160,124, 159,121, 159,119, 160,117, 162,113, 163,112, 163,110, 163,108, 163,107, 162,104, 162,103, 163,102, 165,102, 165,100, 166,99, 168,98, 169,97, 170,94, 170,90, 173,88, 177,88, 179,88, 186,89, 189,89, 191,86, 193,83, 196,82, 200,82, 201,81, 202,79, 204,79, 209,77, 210,75, 213,75, 216,75, 218,74, 223,72, 227,72, 227,80, 228,86, 229,88, 233,91, 235,95, 236,98, 238,101, 241,103, 244,104, 246,104, 247,106, 249,107, 251,107, 254,108, 254,109, 255,112, 256,113, 255,116, 254,119, 255,121, 257,123, 260,126, 264,128, 269,129, 272,129, 274,130, 277,131, 278,131, 276,132, 274,133, 272,136, 269,141, 267,141, 266,141, 263,140, 260,141, 259,142, 259,143, 257,144, 254,144, 249,145, 244,146, 241,147, 239,148, 239,149, 239,150, 240,152, 240,153, 240,154, 239,159, 238,162, 237,165, 236,166, 234,167, 232,167, 232,169, 232,172, 234,174, 236,176, 237,179, 237,184, 236,197, 235,198, 232,198, 230,198, 228,199, 226,200, 225,199, 225,199" />
    <area href="${url(controller='search', action='browse', region_id=8)}" title="Opolskie" shape="poly" coords="110,256, 108,253, 107,251, 105,249, 107,248, 108,247, 108,245, 108,242, 103,242, 97,241, 94,238, 89,234, 84,232, 82,231, 84,229, 86,228, 87,226, 87,225, 88,224, 90,223, 91,221, 94,213, 98,208, 102,202, 103,200, 105,198, 105,197, 104,196, 104,196, 104,195, 107,194, 109,194, 110,196, 111,197, 114,197, 117,197, 119,196, 123,195, 125,195, 126,196, 129,196, 131,197, 133,198, 134,199, 135,201, 135,203, 136,205, 135,208, 133,212, 131,217, 130,220, 130,221, 130,222, 132,224, 133,226, 132,228, 130,230, 128,232, 127,234, 127,239, 128,243, 127,244, 124,246, 119,248, 117,248, 116,249, 116,250, 116,252, 115,255, 113,257, 110,256, 110,256" />
    <area href="${url(controller='search', action='browse', region_id=9)}" title="Podkarpackie" shape="poly" coords="270,304, 264,302, 260,300, 255,298, 253,297, 251,295, 248,291, 245,289, 243,288, 241,287, 236,286, 230,286, 227,280, 225,271, 223,267, 222,266, 220,264, 221,263, 222,262, 223,260, 222,258, 221,256, 220,253, 220,245, 219,242, 221,238, 228,231, 235,225, 241,216, 242,215, 244,215, 246,214, 249,213, 250,214, 250,217, 250,219, 251,221, 253,222, 256,223, 259,224, 261,226, 258,228, 256,230, 255,233, 255,235, 256,237, 258,237, 261,238, 267,239, 275,240, 279,240, 280,238, 282,236, 284,235, 287,236, 290,238, 292,240, 289,245, 284,252, 282,254, 275,267, 274,267, 271,273, 268,278, 269,282, 270,286, 270,291, 270,294, 271,297, 272,300, 275,301, 276,302, 277,304, 276,305, 276,306, 270,304, 270,304" />
    <area href="${url(controller='search', action='browse', region_id=10)}" title="Podlaskie" shape="poly" coords="276,128, 274,127, 270,127, 266,126, 261,124, 256,120, 257,117, 258,115, 259,115, 259,114, 258,111, 256,107, 255,106, 252,105, 250,105, 250,104, 250,103, 247,102, 243,102, 240,99, 238,97, 237,93, 235,90, 231,86, 230,84, 229,78, 228,70, 232,70, 236,68, 240,67, 242,67, 244,66, 250,60, 254,56, 257,53, 261,48, 262,43, 261,42, 260,41, 258,39, 257,36, 257,33, 255,30, 253,29, 257,25, 261,20, 262,19, 263,19, 267,21, 270,23, 273,25, 276,26, 278,28, 280,31, 282,35, 282,39, 282,42, 282,43, 283,44, 284,46, 284,52, 284,55, 285,57, 287,61, 289,68, 291,73, 293,78, 296,87, 298,98, 299,103, 298,106, 297,109, 295,110, 289,113, 286,116, 283,119, 282,122, 282,124, 280,127, 278,129, 277,129, 276,128, 276,128" />
    <area href="${url(controller='search', action='browse', region_id=11)}" title="Pomorskie" shape="poly" coords="90,66, 85,61, 84,59, 84,56, 85,52, 86,51, 86,50, 87,47, 86,44, 85,43, 84,42, 84,38, 84,35, 83,33, 81,31, 83,30, 84,29, 85,28, 85,22, 83,13, 82,12, 85,11, 91,8, 93,6, 97,5, 106,3, 111,1, 115,0, 124,0, 133,0, 134,1, 134,2, 135,6, 136,11, 137,15, 138,18, 140,21, 143,23, 148,23, 154,23, 156,25, 157,27, 156,31, 154,36, 155,37, 156,39, 158,42, 159,44, 161,45, 165,46, 165,47, 162,49, 158,52, 157,52, 156,54, 155,56, 153,58, 151,59, 150,62, 149,64, 147,64, 143,61, 138,59, 132,58, 129,57, 128,56, 125,55, 122,54, 119,55, 118,56, 115,57, 113,58, 111,60, 109,61, 106,61, 102,62, 101,64, 99,66, 97,66, 93,67, 92,67, 90,66, 90,66" />
    <area href="${url(controller='search', action='browse', region_id=12)}" title="Śląskie" shape="poly" coords="149,288, 146,284, 144,281, 143,277, 142,275, 141,273, 136,270, 135,268, 135,266, 135,262, 133,261, 129,260, 127,259, 124,258, 121,255, 119,252, 118,250, 120,249, 126,247, 130,245, 130,243, 129,236, 130,234, 131,231, 134,229, 136,227, 132,220, 133,219, 134,214, 136,209, 138,207, 138,204, 138,201, 138,200, 140,199, 143,199, 146,199, 148,201, 149,203, 153,203, 159,204, 161,205, 161,207, 162,209, 164,210, 166,210, 167,211, 169,212, 170,213, 170,215, 170,218, 172,221, 174,223, 173,225, 172,228, 172,229, 173,230, 174,231, 173,233, 170,234, 167,234, 164,234, 161,237, 157,241, 157,242, 158,243, 159,244, 159,245, 157,248, 153,253, 151,256, 151,258, 152,260, 154,262, 155,265, 155,269, 158,270, 160,272, 162,274, 162,277, 162,278, 161,280, 159,281, 156,283, 155,286, 153,288, 151,289, 149,288, 149,288" />
    <area href="${url(controller='search', action='browse', region_id=13)}" title="Świętokrzyskie" shape="poly" coords="194,244, 192,241, 191,235, 190,231, 189,230, 187,229, 182,229, 175,229, 174,228, 175,227, 176,225, 176,223, 175,221, 173,219, 171,217, 172,214, 173,211, 175,209, 176,206, 177,204, 179,204, 182,205, 182,201, 182,199, 181,198, 181,197, 181,196, 182,195, 185,195, 188,194, 189,193, 190,192, 191,191, 192,190, 192,189, 193,187, 195,186, 196,187, 198,189, 199,190, 200,191, 204,194, 206,195, 210,195, 214,195, 215,196, 216,198, 219,199, 223,201, 224,202, 226,202, 228,202, 230,201, 233,200, 235,200, 236,201, 238,207, 239,213, 238,216, 236,220, 233,224, 231,227, 227,229, 221,234, 219,238, 217,239, 201,244, 197,245, 194,244, 194,244" />
    <area href="${url(controller='search', action='browse', region_id=14)}" title="Warmińsko-mazurskie" shape="poly" coords="181,87, 176,86, 174,86, 172,85, 171,83, 170,81, 170,80, 169,79, 163,75, 157,72, 156,70, 156,68, 156,65, 152,64, 152,63, 152,62, 155,59, 157,58, 157,56, 158,54, 159,54, 161,53, 164,51, 166,48, 167,46, 166,44, 162,43, 160,42, 159,40, 157,37, 157,34, 157,33, 158,32, 159,29, 159,26, 161,26, 166,24, 168,23, 168,21, 169,20, 174,20, 184,21, 201,24, 216,24, 238,23, 252,22, 258,21, 255,24, 253,26, 252,28, 252,30, 254,32, 255,35, 256,38, 256,41, 258,42, 259,44, 259,47, 256,51, 251,55, 246,61, 243,64, 240,65, 231,68, 221,71, 216,72, 215,73, 212,73, 209,74, 207,75, 204,77, 201,78, 199,80, 198,81, 195,81, 191,82, 189,86, 188,87, 186,87, 181,87, 181,87" />
    <area href="${url(controller='search', action='browse', region_id=15)}" title="Wielkopolskie" shape="poly" coords="111,192, 109,184, 108,180, 105,179, 103,178, 102,178, 103,177, 103,175, 103,173, 101,171, 98,169, 95,171, 92,173, 89,173, 85,172, 81,170, 77,167, 76,165, 75,162, 72,159, 67,152, 66,150, 63,151, 60,151, 59,149, 55,144, 53,141, 52,139, 51,136, 52,132, 53,128, 52,125, 51,124, 51,122, 52,121, 51,118, 50,113, 49,112, 50,111, 52,107, 53,103, 56,100, 57,96, 57,94, 60,93, 62,93, 65,91, 68,89, 69,87, 71,85, 73,84, 76,82, 79,77, 78,76, 77,75, 74,73, 73,71, 74,71, 77,70, 79,69, 81,67, 82,65, 82,63, 84,64, 90,68, 92,69, 94,69, 98,69, 98,70, 97,71, 96,73, 96,75, 96,77, 98,79, 100,81, 99,82, 98,83, 96,85, 96,90, 96,96, 97,98, 99,99, 101,101, 102,102, 102,104, 100,105, 99,107, 98,109, 99,111, 100,113, 104,113, 105,113, 106,114, 106,116, 107,117, 108,117, 110,116, 111,115, 112,115, 114,119, 115,120, 117,121, 121,123, 123,124, 125,125, 127,124, 128,123, 128,122, 129,122, 131,124, 132,125, 134,125, 136,126, 137,127, 138,130, 140,131, 142,132, 145,132, 147,131, 149,132, 148,136, 146,139, 144,143, 144,144, 142,145, 140,146, 138,148, 138,151, 139,153, 139,156, 137,157, 135,158, 133,158, 130,158, 129,159, 128,163, 127,170, 126,179, 124,179, 122,178, 120,180, 117,183, 116,184, 117,186, 118,189, 120,191, 121,192, 120,193, 118,194, 114,196, 112,195, 111,192, 111,192" />
    <area href="${url(controller='search', action='browse', region_id=16)}" title="Zachodniopomorskie" shape="poly" coords="11,110, 5,103, 0,97, 3,91, 7,87, 9,81, 11,77, 10,74, 9,67, 8,59, 6,53, 5,51, 6,47, 6,44, 9,44, 15,42, 22,40, 27,37, 33,35, 43,33, 48,31, 51,30, 53,28, 56,28, 61,27, 66,25, 70,22, 73,17, 76,15, 80,13, 81,14, 82,16, 83,22, 83,26, 81,28, 80,29, 79,31, 80,33, 81,35, 82,37, 82,40, 82,43, 83,44, 85,46, 85,47, 85,49, 84,49, 83,51, 82,55, 81,61, 80,64, 80,66, 78,68, 76,69, 73,69, 71,70, 70,71, 71,73, 74,75, 77,77, 74,80, 70,83, 68,85, 66,87, 64,89, 61,91, 59,91, 58,90, 58,88, 58,84, 55,84, 53,85, 52,87, 52,89, 50,89, 45,90, 41,91, 39,92, 36,94, 34,96, 32,97, 26,98, 23,98, 21,100, 19,103, 17,107, 14,109, 12,110, 11,110, 11,110" />
  </map>

%endif

${universities_section(c.unis, url(controller='profile', action='browse'))}
<br class="clear-left" />

