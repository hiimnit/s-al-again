controladdin "Monaco Editor FS"
{
    VerticalStretch = true;
    HorizontalStretch = true;

    StyleSheets = 'src/MonacoEditor/resources/index.css';
    StartupScript = 'src/MonacoEditor/resources/index.js';

    event Tokenize(Input: Text)
    event Parse(Input: Text)
    event Ready()
    event GetSuggestions("Key": Integer; Input: Text; Line: Integer; Column: Integer)
    event EditorReady()

    procedure WriteLine(Line: Text)
    procedure SetEditorValue(Value: Text)
    procedure SetStaticSymbols(Symbols: JsonObject)
    procedure ResolveSuggestionsRequest("Key": Integer; Suggestions: JsonObject)

    procedure SendObject(object: JsonObject)
}