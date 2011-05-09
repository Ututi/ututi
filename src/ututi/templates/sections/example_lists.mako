<%inherit file="/ubase.mako" />
<%namespace name="o" file="/sections/standard_objects.mako" />

<h2>Standart Ututi lists</h2>

<h3>Numbered steps</h3>

<div class="steps">
  <span class="step">
    <span class="number">1</span>
    <span class="title">One</span>
  </span>
  <span class="step active">
    <span class="number">2</span>
    <span class="title">Two (active)</span>
  </span>
  <span class="step">
    <span class="number">3</span>
    <span class="title">Three</span>
  </span>
</div>

<br />
They can also be displayed as blocks:

<div class="steps">
  <div class="step complete">
    <span class="number">1</span>
    <span class="title">Completed item</span>
  </div>
  <div class="step complete">
    <span class="number">2</span>
    <span class="title">Completed item</span>
  </div >
  <div class="step">
    <span class="number">3</span>
    <span class="title">Item that is not completed</span>
  </div>
</div>

<br />
<h3>File list</h3>

<ul class="file-list">
  <li>File number one</li>
  <li>File number two</li>
  <li>File number three</li>
</ul>

<br />
<h3>Teacher list</h3>

<ul class="teacher-list">
  <li>Teacher number one</li>
  <li>Teacher number two</li>
  <li>Teacher number three</li>
</ul>

<br />
<h3>Pros list</h3>

<ul class="pros-list">
  <li>One good thing</li>
  <li>Another good thing</li>
  <li>Last but not least...</li>
</ul>

<br />
<h3>Feature list</h3>

<ul class="feature-list">
  <li class="wiki">
    <strong>Feature wiki</strong>
    Feature description. And it can be long text, normally inlined.
  </li>
  <li class="group">
    <strong>Feature group</strong>
    Feature description. And it can be even longer text.
    Lorem ipsum dolor sit amet, consectetur adipisicing elit, 
    sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
    Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
    nisi ut aliquip ex ea commodo consequat.
    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum
    dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,
    sunt in culpa qui officia deserunt mollit anim id est laborum.
  </li>
  <li class="file-sharing">
    <strong>Feature file-sharing</strong>
    Besides, this is just a simple list.
    Feature names are <code>strong</code> elements.
    (I tried to markup it with definition lists, but couldn't make it very clean.)
  </li>
  <li class="dialog">
    <strong>Feature dialog</strong>
    The icons are set by setting an appropriate class to the <code>li</code> element.
    In this example I used <code>wiki</code>, <code>group</code>, <code>file-sharing</code>
    and <code>dialog</code> classes.
  </li>
</ul>

<br />
<h3>Subject list</h3>

${o.subject_list("An example list", c.example_subjects)}
