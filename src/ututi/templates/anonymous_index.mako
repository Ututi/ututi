<%inherit file="/ubase.mako" />

<%def name="body_class()">noMenu</%def>

<div id="homeSearchNotesBlock">
  <h2>${_('Search for notes')}</h2>
  <p>${_('Your study materials')}</p>
  <ul>
    <li>${_('Subjects and files')}</li>
    <li>${_('Shared lecture notes')}</li>
    <li>${_('Universities and departments')}</li>
  </ul>
  <form method="get" action="${url(controller='search', action='index')}" id="search_form_portlet">
    <fieldset>
      <label class="textField textFieldBig">
        <span class="a11y">${_('Enter the search string')}: </span><input name="text" type="text"><span class="edge"></span>
      </label>
      <button type="submit" class="btnMedium"><span>${_('search_fp')}</span></button>
    </fieldset>
  </form>
</div><div id="homeRegisterBlock">
  <h2>${_('Join')}</h2>

  <div id="registrationForm" class="${'shown' if c.show_registration else 'hidden'}">
  <form id="registration_form" method="post" action="${url(controller='home', action='register')}">
    <fieldset>
      %if c.hash:
        <input type="hidden" name="hash" value="${c.hash}"/>
      %endif
      <form:error name="came_from"/>
      %if c.came_from:
        <input type="hidden" name="came_from" value="${c.came_from}" />
      %endif
      <form:error name="fullname"/>
      <label>
        <span class="labelText">${_('Full name')}</span>
        <span class="textField">
          <input type="text" name="fullname"/>
          <span class="edge"></span>
        </span>
      </label>
      <form:error name="email"/>
      <label>
        <span class="labelText">${_('Email')}</span>
        <span class="textField">
          <input type="text" name="email" value="${c.email}"/>
          <span class="edge"></span>
        </span>
      </label>
      %if c.gg_enabled:
      <form:error name="gadugadu"/>
      <label>
        <span class="labelText">${_('Gadu gadu')}</span>
        <span class="textField">
          <input type="text" name="gadugadu" value=""/>
          <span class="edge"></span>
        </span>
      </label>
      %else:
      <input type="hidden" id="gadugadu" name="gadugadu"/>
      %endif

      <form:error name="new_password"/>
      <label>
        <span class="labelText">${_('Password')}</span>
        <span class="textField">
          <input type="password" name="new_password" />
          <span class="edge"></span>
        </span>
      </label>
      <form:error name="repeat_password"/>
      <label>
        <span class="labelText">${_('Repeat password')}</span>
        <span class="textField">
          <input type="password" name="repeat_password"/>
          <span class="edge"></span>
        </span>
      </label>
      <form:error name="agree"/>
      <label id="agreeWithTOC"><input type="checkbox" name="agree" value="true"/>${_('I agree to the ')} <a href="" onclick="return false;">${_('terms of use')}</a></label>
      <div style="text-align: center;">
        <button class="btnLarge" type="submit" value="${_('Register')}"><span>${_('Register')}</span></button>
      </div>
    </fieldset>
  </form>
  </div>
  <div id="registrationTeaser" class="${'hidden' if c.show_registration else ''}">
    <img src="${url('/img/person.png')}" alt="${_('Register')}"/>
    <div id="homeRegisterWelcome">
      ${_('home_register_welcome')}
    </div>
    <div class="homeRegisterStep">
      <button class="btnLarge" type="button" id="homeRegisterStep"><span>${_('register')}</span></button>
    </div>
    <script type="text/javascript">
      $('#homeRegisterStep').click(function() {
          $('#registrationTeaser').addClass('hidden');
          $('#registrationForm').removeClass('hidden');
      });
    </script>
  </div>
</div><div id="homeCreateGroupBlock">
  <h2>Sukurk grupę</h2>
  <p>Ką turi grupės</p>
  <ul>
    <li style="background-image: url('img/icons/comment_green_17.png');">El. pašto konferenciją arba forumą</li>
    <li style="background-image: url('img/icons/file_private_green_17.png');">Privačių failų saugyklą</li>
    <li style="background-image: url('img/icons/subjects_green_17.png');">Studijuojamus dalykus</li>
  </ul>
  <table style="width: 100%;">
    <tr><td style="text-align: center;">
        ${h.button_to(_('Create group'), url(controller='group', action='group_type'),  method='GET', class_='btnPlus btnLarge')}
    </td></tr>
  </table>
</div>
<div id="homePopularSubjects">
  <h2>Populiariausi dalykai</h2>
  <ul>
    <li>      <dl>
        <dt><a href="">Citologija</a></dt>
        <dd class="files"><span class="a11y">Failų:</span> 30</dd>
        <dd class="pages"><span class="a11y">Wiki puslapių:</span> 0</dd>
        <dd class="watchedBy"><span class="a11y">Dalyką stebi:</span> 0 grupių ir 4 nariai</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Parazitologija</a></dt>
        <dd class="files"><span class="a11y">Failų:</span> 30</dd>
        <dd class="pages"><span class="a11y">Wiki puslapių:</span> 0</dd>
        <dd class="watchedBy"><span class="a11y">Dalyką stebi:</span> 0 grupių ir 4 nariai</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Chirurginė medicina</a></dt>
        <dd class="files"><span class="a11y">Failų:</span> 30</dd>
        <dd class="pages"><span class="a11y">Wiki puslapių:</span> 0</dd>
        <dd class="watchedBy"><span class="a11y">Dalyką stebi:</span> 0 grupių ir 4 nariai</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Matematinė analizė</a></dt>
        <dd class="files"><span class="a11y">Failų:</span> 30</dd>
        <dd class="pages"><span class="a11y">Wiki puslapių:</span> 0</dd>
        <dd class="watchedBy"><span class="a11y">Dalyką stebi:</span> 0 grupių ir 4 nariai</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Ekonometrija</a></dt>
        <dd class="files"><span class="a11y">Failų:</span> 30</dd>
        <dd class="pages"><span class="a11y">Wiki puslapių:</span> 0</dd>
        <dd class="watchedBy"><span class="a11y">Dalyką stebi:</span> 0 grupių ir 4 nariai</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Finansų ir draudimo matematika</a></dt>
        <dd class="files"><span class="a11y">Failų:</span> 30</dd>
        <dd class="pages"><span class="a11y">Wiki puslapių:</span> 0</dd>
        <dd class="watchedBy"><span class="a11y">Dalyką stebi:</span> 0 grupių ir 4 nariai</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Kompozicija</a></dt>
        <dd class="files"><span class="a11y">Failų:</span> 30</dd>
        <dd class="pages"><span class="a11y">Wiki puslapių:</span> 0</dd>
        <dd class="watchedBy"><span class="a11y">Dalyką stebi:</span> 0 grupių ir 4 nariai</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Visuomeninio pastato techninis projektas</a></dt>
        <dd class="files"><span class="a11y">Failų:</span> 30</dd>
        <dd class="pages"><span class="a11y">Wiki puslapių:</span> 0</dd>
        <dd class="watchedBy"><span class="a11y">Dalyką stebi:</span> 0 grupių ir 4 nariai</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Vadyba</a></dt>
        <dd class="files"><span class="a11y">Failų:</span> 30</dd>
        <dd class="pages"><span class="a11y">Wiki puslapių:</span> 0</dd>
        <dd class="watchedBy"><span class="a11y">Dalyką stebi:</span> 0 grupių ir 4 nariai</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Vadyba II</a></dt>
        <dd class="files"><span class="a11y">Failų:</span> 30</dd>
        <dd class="pages"><span class="a11y">Wiki puslapių:</span> 0</dd>
        <dd class="watchedBy"><span class="a11y">Dalyką stebi:</span> 0 grupių ir 4 nariai</dd>
      </dl>
    </li>
  </ul>
</div><div id="homeActiveUniversities">
  <h2>Aktyviausi universitetai</h2>
  <ul>
    <li style="background-image: url('tmp/vgtu.png');">
      <dl>
        <dt><a href="">Vilniaus Gedimino technikos universitetas</a></dt>
        <dd>120 dalykų, 23 grupės, 2212 failų</dd>
      </dl>
    </li>
    <li style="background-image: url('tmp/vgtu.png');">
      <dl>
        <dt><a href="">Kauno kolegija</a></dt>
        <dd>120 dalykų, 23 grupės, 2212 failų</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Vilniaus Gedimino technikos universitetas</a></dt>
        <dd>120 dalykų, 23 grupės, 2212 failų</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Vilniaus universitetas</a></dt>
        <dd>120 dalykų, 23 grupės, 2212 failų</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Kauno miškų agrokultūros ir inžinerijos akademija</a></dt>
        <dd>120 dalykų, 23 grupės, 2212 failų</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Lietuvos muzikos ir teatro akademija</a></dt>
        <dd>120 dalykų, 23 grupės, 2212 failų</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Vilniaus ekonomikos ir verslo kolegija</a></dt>
        <dd>120 dalykų, 23 grupės, 2212 failų</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Kauno medicinos universitetas</a></dt>
        <dd>120 dalykų, 23 grupės, 2212 failų</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Klaipėdos universitetas</a></dt>
        <dd>120 dalykų, 23 grupės, 2212 failų</dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Mykolo Romerio universitetas</a> </dt>
        <dd>120 dalykų, 23 grupės, 2212 failų</dd>
      </dl>
    </li>
  </ul>
  <p class="more"><a href="">Visi universitetai</a></p>
</div><div id="homeActiveGroups">
  <h2>Aktyviausios grupės</h2>
  <ul>
    <li>
      <dl>
        <dt><a href="">Citologija</a></dt>
        <dd><a href="" title="Vilniaus universitetas">VU</a> | <a href="" title="Matematikos ir informatikos fakultetas">MIF</a></dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Parazitologija</a></dt>
        <dd><a href="" title="Kauno medicinos universitetas">KMU</a> | <a href="" title="Kažkoks fakultetas">KF</a></dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Chirurginė medicina</a></dt>
        <dd><a href="" title="Vilniaus universitetas">VU</a> | <a href="" title="Medicinos fakultetas">MF</a></dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Matematinė analizė</a></dt>
        <dd><a href="" title="Vilniaus universitetas">VU</a> | <a href="" title="Matematikos ir informatikos fakultetas">MIF</a></dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Ekonometrija</a></dt>
        <dd><a href="" title="Vilniaus universitetas">VU</a> | <a href="" title="Matematikos ir informatikos fakultetas">MIF</a></dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Finansų ir draudimo matematika</a></dt>
        <dd><a href="" title="Vilniaus universitetas">VU</a> | <a href="" title="Matematikos ir informatikos fakultetas">MIF</a></dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Kompozicija</a></dt>
        <dd><a href="" title="Vilniaus statybos ir dizaino kolegija">VSDK</a> | <a href="" title="Architektūros fakultetas">AF</a></dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Visuomeninio pastato techninis projektas</a></dt>
        <dd><a href="" title="Vilniaus statybos ir dizaino kolegija">VSDK</a> | <a href="" title="Architektūros fakultetas">AF</a></dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Vadyba</a></dt>
        <dd><a href="" title="Vilniaus universitetas">VU</a> | <a href="" title="Ekonomikos fakultetas">EF</a></dd>
      </dl>
    </li>
    <li>
      <dl>
        <dt><a href="">Vadyba II</a></dt>
        <dd><a href="" title="Vilniaus universitetas">VU</a> | <a href="" title="Ekonomikos fakultetas">EF</a></dd>
      </dl>
    </li>
  </ul>
</div>

