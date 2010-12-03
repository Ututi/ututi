<%inherit file="/books/base.mako" />
<%namespace file="/books/index.mako" name="books" import="book_information"/>

<div class="portlet portletSmall search_block">
  <div class="ctl"></div>
  <div class="ctr"></div>
  <div class="cbl"></div>
  <div class="cbr"></div>

<div class="inner">
  <h2 class="portletTitle bold">Paieška</h2>
  <div class="search-controls">
    <form method="get" action="${url(controller='books', action='search')}" id="search_form">
      <div class="search-text-submit">
        <div class="search-text">
          <div>
            <input type="text" name="text" id="text" value="${c.search_text}" size="60"/>
          </div>
        </div>
        <div class="search-submit">
          <button class="btnMedium" type="submit" value="${_('Search-btn')}" id="search-btn">
            <span>
              ${_('Search-btn')}
            </span>
          </button>
        </div>
        <br style="clear: left;"/>
      </div>
    </form>
  </div>
</div>
</div>

<div id="search_results_header">
  <h2>Search results</h2>
  <div id="city_select_dropdown">${h.select(None, None, [('Visi miestai (1100)', 'Visi miestai (1100)')])}</div>
  <br style="clear: both;"/>
</div>

<div>
  %for search_item in c.books:
  <%books:book_information book="${search_item.object}" />
  %endfor
  <div id="pager">${c.books.pager(format='~3~') }</div>
</div>
