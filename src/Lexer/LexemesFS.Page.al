page 69001 "Lexemes FS"
{
    Caption = 'Lexemes';
    PageType = List;
    UsageCategory = None;
    ApplicationArea = All;
    SourceTable = "Lexeme FS";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { }
                field(Type; Rec.Type) { }
                field(Value; Rec.GetValue()) { Caption = 'Value'; }
            }
        }
    }
}