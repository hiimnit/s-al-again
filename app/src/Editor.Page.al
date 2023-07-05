page 69000 "Editor FS"
{
    Caption = 'Editor';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            usercontrol(Editor; "Monaco Editor FS")
            {
                ApplicationArea = All;

                trigger Tokenize(Input: Text)
                var
                    Lexeme: Record "Lexeme FS";
                    Lexer: Codeunit "Lexer FS";
                    i: Integer;
                begin
                    Lexer.Init(Input);
                    i := 1;
                    repeat
                        Lexeme := Lexer.Next();
                        Lexeme."Entry No." := i;
                        Lexeme.Insert();
                        i += 1;
                    until Lexeme.Type = Lexeme.Type::EOS;

                    Page.Run(Page::"Lexemes FS", Lexeme);
                end;

                trigger Parse(Input: Text)
                var
                    Parser: Codeunit "Parser FS";
                    Runtime: Codeunit "Runtime FS";
                    Runner: Codeunit "Runner FS";
                begin
                    Runtime.Init(CurrPage.Editor);

                    Parser.Parse(Input, Runtime);

                    Runner.Execute(Runtime);
                end;

                trigger GetSuggestions("Key": Integer; Input: Text)
                var
                    Parser: Codeunit "Parser FS";
                    Runtime: Codeunit "Runtime FS";

                    ParsingResult: JsonObject;
                begin
                    Runtime.Init(CurrPage.Editor);

                    // TODO call parser - with recovery
                    // we need:
                    // 1. function definitions - only name + params - store position
                    // 2. local symbol table - we need to identify the enclosing function
                    // 3. context suggestions - we need to identify the enclosing function + current position - only send the current function to the cursor
                    // >>>> for record definition - only in var definitions
                    // >>>> field/method suggestions - only in function body

                    ParsingResult := Parser.ParseForIntellisense(Input, Runtime);

                    CurrPage.Editor.ResolveSuggestionsRequest("Key", ParsingResult);
                end;

                trigger EditorReady()
                var
                    Runtime: Codeunit "Runtime FS";
                    LF: Text[1];
                begin
                    LF[1] := 13;

                    CurrPage.Editor.SetEditorValue(
                        'trigger OnRun()' + LF
                        + 'begin' + LF
                        + 'end;'
                    );

                    CurrPage.Editor.SetStaticSymbols(
                        Runtime.PrepareStaticSymbols()
                    );
                end;
            }
        }
    }
}