controladdin "Monaco Editor FS"
{
    VerticalStretch = true;
    HorizontalStretch = true;

    StyleSheets = 'src/MonacoEditor/resources/index.css';
    StartupScript = 'src/MonacoEditor/resources/index.js';

    event Tokenize(Input: Text)
    event Parse(Input: Text)
    event Ready()

    procedure WriteLine(Line: Text)
}