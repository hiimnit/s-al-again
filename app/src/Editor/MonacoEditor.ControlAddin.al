controladdin "Monaco Editor FS"
{
    // RequestedHeight = 300;
    // MinimumHeight = 300;
    // MaximumHeight = 300;
    // RequestedWidth = 700;
    // MinimumWidth = 700;
    // MaximumWidth = 700;
    VerticalStretch = true;
    // VerticalShrink = true;
    HorizontalStretch = true;
    // HorizontalShrink = true;
    // Scripts =
    //     'script1.js',
    //     'script2.js';
    // Scripts = 'src/Editor/resources/startup.js';
    StyleSheets = 'src/Editor/resources/index-c529927f.css';
    StartupScript = 'src/Editor/resources/index-8b8b0aeb.js';
    // RecreateScript = 'recreateScript.js';
    // RefreshScript = 'refreshScript.js';
    // Images =
    //     'image1.png',
    //     'image2.png';

    event Tokenize(Input: Text)
    event Parse(Input: Text)
    event Ready()
}