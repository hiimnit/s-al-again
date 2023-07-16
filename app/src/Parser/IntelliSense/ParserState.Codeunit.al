codeunit 69003 "Parser State FS"
{
    var
        State: Enum "Parser State FS";

    procedure GetState(): Enum "Parser State FS"
    begin
        exit(State);
    end;

    procedure None()
    begin
        State := State::None;
    end;

    procedure VarOrIdentifier()
    begin
        State := State::VarOrIdentifier;
    end;

    procedure Identifier()
    begin
        State := State::Identifier;
    end;

    procedure Type()
    begin
        State := State::Type;
    end;

    var
        SubtypeOfType: Enum "Type FS";

    procedure SubtypeOf(NewType: Enum "Type FS")
    begin
        State := State::SubtypeOf;
        SubtypeOfType := NewType;
    end;

    procedure TypeLength()
    begin
        State := State::TypeLength;
    end;

    procedure Statement()
    begin
        State := State::Statement;
    end;

    procedure Expression()
    begin
        State := State::Expression;
    end;

    var
        Call: Interface "Node FS";

    procedure PropsOf(NewCall: Interface "Node FS")
    begin
        State := State::PropsOf;
        Call := NewCall;
    end;

    procedure ProcedureOrTrigger()
    begin
        State := State::ProcedureOrTrigger;
    end;

    procedure VarOrBegin()
    begin
        State := State::VarOrBegin;
    end;

    procedure IdentifierOrBegin()
    begin
        State := State::IdentifierOrBegin;
    end;

    procedure Unfinished()
    begin
        State := State::Unfinished;
    end;

    var
        KeywordCounter: Dictionary of [Enum "Keyword FS", Integer];

    procedure PushKeyword(Keyword: Enum "Keyword FS")
    var
        Count: Integer;
    begin
        if not KeywordCounter.Get(Keyword, Count) then
            Count := 0;

        KeywordCounter.Set(Keyword, Count + 1);
    end;

    procedure PopKeyword(Keyword: Enum "Keyword FS")
    var
        Count: Integer;
    begin
        if not KeywordCounter.Get(Keyword, Count) then
            Count := 0;

        Count -= 1;

        if Count <= 0 then begin
            KeywordCounter.Remove(Keyword);
            exit;
        end;

        KeywordCounter.Set(Keyword, Count);
    end;

    procedure ToSuggestions
    (
        Runtime: Codeunit "Runtime FS";
        CurrentUserFunction: Codeunit "User Function FS"
    ): JsonObject
    var
        Symbol: Record "Symbol FS";
        Suggestions, PropsOfDetails : JsonObject;
    begin
        case State of
            Enum::"Parser State FS"::None:
                ;
            Enum::"Parser State FS"::Unfinished:
                Suggestions.Add('unfinished', true);
            Enum::"Parser State FS"::Identifier:
                Suggestions.Add('identifier', true);
            Enum::"Parser State FS"::ProcedureOrTrigger:
                Suggestions.Add('keywords', KeywordsSuggestions());
            Enum::"Parser State FS"::Statement:
                begin
                    Suggestions.Add('keywords', KeywordsSuggestions());
                    Suggestions.Add('variables', true);
                    Suggestions.Add('functions', true);
                end;
            Enum::"Parser State FS"::Expression:
                begin
                    Suggestions.Add('keywords', KeywordsSuggestions());
                    Suggestions.Add('variables', true);
                    Suggestions.Add('functions', true);
                end;
            Enum::"Parser State FS"::PropsOf:
                begin
                    if TryGetPropsOfSymbol(
                        Runtime,
                        CurrentUserFunction,
                        Symbol
                    ) then begin
                        PropsOfDetails.Add('type', Format(Symbol.Type));
                        PropsOfDetails.Add('subtype', Symbol.TryLookupSubtype());
                    end else begin
                        PropsOfDetails.Add('type', 'Unknown');
                        PropsOfDetails.Add('subtype', -1);
                    end;

                    Suggestions.Add(
                        'propsOf',
                        PropsOfDetails
                    );
                end;
            Enum::"Parser State FS"::SubtypeOf:
                Suggestions.Add(
                    'subtypesOf',
                    Format(SubtypeOfType)
                );
            Enum::"Parser State FS"::Type:
                Suggestions.Add('types', true);
            Enum::"Parser State FS"::TypeLength:
                ; // TODO suggest common lengths? 20/10/50?
            Enum::"Parser State FS"::VarOrBegin:
                Suggestions.Add('keywords', KeywordsSuggestions());
            Enum::"Parser State FS"::IdentifierOrBegin:
                Suggestions.Add('keywords', KeywordsSuggestions());
            Enum::"Parser State FS"::VarOrIdentifier:
                begin
                    Suggestions.Add('keywords', KeywordsSuggestions());
                    Suggestions.Add('identifier', true);
                end;
        end;

        exit(Suggestions);
    end;

    local procedure KeywordsSuggestions(): JsonArray
    var
        Keywords: JsonArray;
    begin
        case State of
            Enum::"Parser State FS"::ProcedureOrTrigger:
                begin
                    Keywords.Add('procedure');
                    Keywords.Add('trigger');
                    exit(Keywords);
                end;
            Enum::"Parser State FS"::VarOrBegin:
                begin
                    Keywords.Add('var');
                    Keywords.Add('begin');
                    exit(Keywords);
                end;
            Enum::"Parser State FS"::IdentifierOrBegin:
                begin
                    Keywords.Add('begin');
                    exit(Keywords);
                end;
            Enum::"Parser State FS"::VarOrIdentifier:
                begin
                    Keywords.Add('var');
                    exit(Keywords);
                end;
        end;

        Keywords.Add('begin');
        Keywords.Add('if');
        Keywords.Add('else');
        Keywords.Add('repeat');
        Keywords.Add('for');
        Keywords.Add('while');
        Keywords.Add('not');
        Keywords.Add('break');
        Keywords.Add('exit');

        if KeywordCounter.ContainsKey(Enum::"Keyword FS"::"begin") then
            Keywords.Add('end');

        if KeywordCounter.ContainsKey(Enum::"Keyword FS"::"if") then
            Keywords.Add('then');

        if KeywordCounter.ContainsKey(Enum::"Keyword FS"::"repeat") then
            Keywords.Add('until');

        if KeywordCounter.ContainsKey(Enum::"Keyword FS"::"for") then begin
            Keywords.Add('to');
            Keywords.Add('downto');
        end;

        if KeywordCounter.ContainsKey(Enum::"Keyword FS"::"do")
            or KeywordCounter.ContainsKey(Enum::"Keyword FS"::"while")
        then
            Keywords.Add('do');

        exit(Keywords);
    end;

    [TryFunction]
    local procedure TryGetPropsOfSymbol
    (
        Runtime: Codeunit "Runtime FS";
        CurrentUserFunction: Codeunit "User Function FS";
        var Symbol: Record "Symbol FS"
    )
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        SymbolTable := CurrentUserFunction.GetSymbolTable();

        Symbol := Call.ValidateSemantics(
            Runtime,
            SymbolTable
        );
    end;
}