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
        ${_('Communicate in the virtual space of Your university, join groups, exchange information.')}
      </p>
    </div>
    <div class="feature_block" style="position: absolute; top: 190px; left: 370px;">
      <strong>${_('Teacher profiles')}</strong>
      <p>
        ${_('Teacher profiles on Ututi, will be able to upload course materials and '
            'easily communicate with their students.')}
      </p>
    </div>
    <div class="feature_block" style="position: absolute; top: 340px; left: 270px;">
      <strong>${_('Discussions')}</strong>
      <p>
        ${_('Discuss not only within groups, but also comment on subjects and uploaded files.')}
      </p>
    </div>

</div>
