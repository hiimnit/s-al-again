controladdin "Monaco Editor FS"
{
    VerticalStretch = true;
    HorizontalStretch = true;

    StyleSheets = 'src/MonacoEditor/resources/index-dd053950.css';
    StartupScript = 'src/MonacoEditor/resources/index-fe7da3b9.js';

    event Tokenize(Input: Text)
    event Parse(Input: Text)
    event Ready()

    procedure WriteLine(Line: Text)
}