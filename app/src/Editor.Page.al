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
            actionref("Parse Promoted"; Parse) { }
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
            action(Parse)
            {
                Caption = 'Parse';
                ApplicationArea = All;

                trigger OnAction()
                var
                    Parser: Codeunit "Parser FS";
                begin
                    Parser.Init(Input);
                    Parser.Parse();
                end;
            }
            action(Test)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    i: Decimal;
                begin
                    for i := 1 to Get10() do
                        ;
                    Message('i := 1 to Get10(): %1', i);

                    for i := Get10() downto 1 do
                        ;
                    Message('i := Get10() downto 1: %1', i);

                    for i := 1 to 1.5 do
                        Message('i := 1 to 1.5: %1', i);
                    Message('>> i := 1 to 1.5: %1', i);

                    for i := 3.5 to 5.1 do
                        Message('i := 3.5 to 5.1: %1', i);
                    Message('>> i := 3.5 to 5.1: %1', i);
                end;
            }
            action("Expression Tests")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    i: Decimal;
                begin
                    if true <> false <> true then
                        ;

                    if true = false = true then
                        ;

                    if 1 = 1 = true then
                        ;
                    if 1 <> 1 + 1 = true and false then
                        ;
                end;
            }
        }
    }

    local procedure Get10(): Integer
    begin
        Message('Get10');
        exit(10);
    end;

    var
        Input: Text;
}