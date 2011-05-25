/*
Copyright (c) 2003-2009, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
    // Define changes to default configuration here. For example:
    config.language = lang;
    // config.uiColor = '#AADC6E';
    config.toolbar = 'UToolBar';

    config.resize_enabled = false;
    config.resize_maxWidth = '620px';

    config.toolbar_UToolBar =
    [
        ['Bold','Italic','Underline','Strike','Subscript','Superscript','Format'],
        ['Cut','Copy','Paste','PasteText','PasteFromWord', 'Source'],
        ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote', 'Table'],
        ['Link','Unlink','Anchor', 'Image'],
    ];

};
