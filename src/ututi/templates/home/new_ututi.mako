<%inherit file="/ubase.mako" />

<%def name="flash_messages()">
</%def>

<%def name="css()">
  #features_content {
    height: 450px;
    background: transparent url("/images/features_bg.png") left top no-repeat;
    position: relative;
  }
  .feature_block p { margin-top: 10px; }
</%def>

<div id="features_content">
    <div class="feature_block" style="position: absolute; top: 40px; left: 270px;">
      <strong>${_('Social network for Your university')}</strong>
      <p>
        ${_('Communicate in the virtual space of your university - with your classmates and your teachers.'
            'Join groups and participate in discussions, share information and knowledge.')}
      </p>
    </div>
    <div class="feature_block" style="position: absolute; top: 190px; left: 370px;">
      <strong>${_('Teacher profiles')}</strong>
      <p>
        ${_('Teacher profiles on Ututi - a clean and simple way to have personal homepages for teachers.'
            'Easy to use tools for communication with students and for publishing lecture notes.')}
      </p>
    </div>
    <div class="feature_block" style="position: absolute; top: 340px; left: 270px;">
      <strong>${_('Discussions')}</strong>
      <p>
        ${_('Discuss any topic not only with Your classmates, but with all students and teachers at your university.'
            'In Ututi everything is a starting point for a discussion - from an uploaded file to a new wiki note.')}
      </p>
    </div>

</div>
