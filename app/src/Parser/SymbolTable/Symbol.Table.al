table 69001 "Symbol FS"
{
    Caption = 'Symbol';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; Name; Text[120])
        {
            Caption = 'Name';
        }
        field(2; Type; Enum "Type FS")
        {
            Caption = 'Type';
        }
    }

    keys
    {
        key(PK; Name) { Clustered = true; }
    }
}