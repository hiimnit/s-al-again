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
        field(3; Scope; Enum "Scope FS")
        {
            Caption = 'Scope';
        }
        field(4; Order; Integer)
        {
            Caption = 'Order';
        }
    }

    keys
    {
        key(PK; Name) { Clustered = true; }
        key(Order; Order) { }
    }

    procedure InsertNumber
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Number,
            NewOrder
        );
    end;

    procedure InsertText
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Text,
            NewOrder
        );
    end;

    procedure InsertBoolean
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Boolean,
            NewOrder
        );
    end;

    procedure InsertParameter
    (
        NewName: Text[120];
        NewType: Enum "Type FS";
        NewOrder: Integer
    )
    begin
        Rec.Init();
        Rec.Name := NewName;
        Rec.Type := NewType;
        Rec.Scope := Rec.Scope::Parameter;
        Rec.Order := NewOrder;
        Rec.Insert();
    end;
}

enum 69004 "Scope FS"
{
    Caption = 'Scope';

    value(1; "Local") { Caption = 'Local'; }
    value(2; "Parameter") { Caption = 'Parameter'; }
}