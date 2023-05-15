table 69003 "Function Parameter FS"
{
    Caption = 'Function';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; Order; Integer)
        {
            Caption = 'Order';
        }
        field(2; Type; Enum "Type FS") // TODO type is not enough - records need subtype - that is why symbol table was created
        {
            Caption = 'Type';
        }
    }

    keys
    {
        key(PK; Order) { Clustered = true; }
    }
}