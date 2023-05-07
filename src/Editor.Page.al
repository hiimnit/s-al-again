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
            group(General)
            {
                Caption = 'General';

                group("Input Group")
                {
                    Caption = 'Input';

                    field(Input; Input)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        MultiLine = true;
                    }
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref("Tokenize Promoted"; Tokenize) { }
        }

        area(Processing)
        {
            action(Tokenize)
            {
                Caption = 'Tokenize';
                ApplicationArea = All;

                trigger OnAction()
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
            }
        }
    }

    var
        Input: Text;
}