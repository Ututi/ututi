<%inherit file="/ubase-nomenu.mako" />

<%def name="css()">
#vote_link {
  font-size: 14px;
  font-weight: bold;
  text-align: center;
  padding: 10px 0;
}

#moved {
   text-align: center;
   margin-top: 30px;
   height: 300px;
}

#moved .underline {
   width: 800px;
   border-bottom: 1px solid #666;
   margin: auto;
}

#moved #search_form_portlet {
   margin-top: 40px;
}

#moved input {
   background: url("img/moved_input.png") no-repeat scroll left top transparent;
   height: 40px;
   width: 450px;
   padding-left: 10px;
}

#moved .browse {
   margin-top: 10px;
   margin-left: 160px;
   text-align: left;
   font-size: 14px;
}

#moved .browse a {
   font-size: 18px;
   font-weight: bold;
}

</%def>

<div id="moved">
  <div class="underline"><a href="http://ututi.com"><img src="/img/moved.png" alt="Ututi.lt moved to Ttuti.com"/></a></div>
  <form method="get" action="${url(controller='search', action='index')}" id="search_form_portlet">
    <fieldset>
      <label class="textField textFieldBig">
        <span class="a11y">${_('Enter the search string')}: </span>
        <input name="text" type="text">
      </label>
      <button type="submit" class="btnLarge"><span>Ieškoti konspektų</span></button>
    </fieldset>
  </form>
  <div class="browse">Arba naršyk <a href="/browse">konspektų archyve</a></div>
</div>
