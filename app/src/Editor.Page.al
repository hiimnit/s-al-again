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
                begin
                    Parser.Init(Input);
                    Parser.Parse(CurrPage.Editor);
                end;
            }
        }
    }
}