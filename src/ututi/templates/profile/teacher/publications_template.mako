<p>
  ${_("List your publications that you consider most important, "
      "starting with most recent.")}
  ${_("If the list is very long, organize your publications into "
      "sections as shown below.")}
</p>

<h2>${_("Textbooks")}</h2>

<ul>
  <li>
    ${_("Authors")}.  <a href="#"> <i>${_("Title")}</i></a>.
    ${_("Name of series and volume")}, ${_("Year")}, ${_("Publishing house")},
    XXX p., ISBN XXX-XX-XXXX-XXX-X.
  </li>
</ul>

<h2>${_("Papers")}</h2>

<ol>
  %for i in range(3):
  <li>
    ${_("Authors")}.  <b>${_("Title")}</b>.
    <a href="#"><i>${_("Journal title")}</i></a>,
    <a href="#">${_("Volume/issue")}</a>,
    ${_("Year")}, p. XXX-XXX,
    <a href="#">(PDF)</a>.
  </li>
  %endfor
</ol>
