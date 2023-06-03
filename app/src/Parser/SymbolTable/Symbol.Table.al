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
        field(3; Subtype; Text[120])
        {
            Caption = 'Subtype';
        }
        field(10; Scope; Enum "Scope FS")
        {
            Caption = 'Scope';
        }
        field(11; Order; Integer)
        {
            Caption = 'Order';
        }
        field(20; Property; Boolean)
        {
            Caption = 'Property';
        }
        field(30; "Pointer Parameter"; Boolean)
        {
            Caption = 'Pointer Parameter';
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
            NewOrder,
            false
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
            NewOrder,
            false
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
            NewOrder,
            false
        );
    end;

    procedure InsertDate
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Date,
            NewOrder,
            false
        );
    end;

    procedure InsertTime
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Time,
            NewOrder,
            false
        );
    end;

    procedure InsertDateTime
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Boolean,
            NewOrder,
            false
        );
    end;

    procedure InsertGuid
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Guid,
            NewOrder,
            false
        );
    end;

    procedure InsertDateFormula
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::DateFormula,
            NewOrder,
            false
        );
    end;

    procedure InsertAny
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Any,
            NewOrder,
            false
        );
    end;

    procedure InsertVarAny
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Any,
            NewOrder,
            true
        );
    end;

    procedure InsertParameter
    (
        NewName: Text[120];
        NewType: Enum "Type FS";
        NewOrder: Integer;
        NewPointerParameter: Boolean
    )
    begin
        Rec.Init();
        Rec.Name := NewName;
        Rec.Type := NewType;
        Rec.Scope := Rec.Scope::Parameter;
        Rec.Order := NewOrder;
        Rec."Pointer Parameter" := NewPointerParameter;
        Rec.Insert();
    end;

    procedure ValidateType()
    var
        AllObj: Record AllObj;
    begin
        case Rec.Type of
            Rec.Type::Record:
                begin
                    if Rec.Subtype = '' then
                        Error('Missing record subtype definition.');
                    AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
                    AllObj.SetRange("Object Name", Rec.Subtype);
                    if AllObj.IsEmpty() then
                        Error('Table "%1" does not exist.', Rec.Subtype);
                end;
        end;
    end;

    procedure CompareExact(Other: Record "Symbol FS"): Boolean
    begin
        if Rec.Type <> Other.Type then
            exit(false);
        if Rec.Subtype <> Other.Subtype then
            exit(false);
        exit(true);
    end;

    procedure CorercibleTo(Target: Record "Symbol FS"): Boolean
    begin
        case Rec.Type of
            Rec.Type::Text:
                exit(Target.Type in [Target.Type::Guid]);
            Rec.Type::Guid:
                exit(Target.Type in [Target.Type::Text]);
        end;

        exit(false);
    end;

    procedure TypeToText(): Text
    var
        FormatTok: Label '%1 "%2"', Locked = true;
    begin
        if Rec.Subtype = '' then
            exit(Format(Rec.Type));
        exit(StrSubstNo(FormatTok, Rec.Type, Rec.Subtype));
    end;

    procedure LookupProperty
    (
        SymbolTable: Codeunit "Symbol Table FS";
        PropertyName: Text[120]
    ): Record "Symbol FS"
    var
        AllObj: Record AllObj;
        Field: Record Field;
    begin
        if Rec.Type <> Rec.Type::Record then
            Error('Type %1 does not support property access.', Rec.Type);

        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        AllObj.SetRange("Object Name", Rec.Subtype);
        if not AllObj.FindFirst() then
            Error('Table "%1" does not exist.', Rec.Subtype);

        Field.SetRange(TableNo, AllObj."Object ID");
        Field.SetRange(FieldName, PropertyName);
        if not Field.FindFirst() then
            Error('Field "%1" does not exist in table "%2".', PropertyName, Rec.Subtype);
        if not Field.Enabled then
            Error('Field "%1" from table "%2" is not enabled.', PropertyName, Rec.Subtype);
        if Field.ObsoleteState = Field.ObsoleteState::Removed then
            Error('Field "%1" from table "%2" is obsolete.', PropertyName, Rec.Subtype);

        case Field.Type of
            Field.Type::Integer,
            Field.Type::Decimal:
                exit(SymbolTable.NumericSymbol());
            Field.Type::Boolean:
                exit(SymbolTable.BooleanSymbol());
            Field.Type::Code,
            Field.Type::Text:
                exit(SymbolTable.TextSymbol());
            Field.Type::Date:
                exit(SymbolTable.DateSymbol());
            Field.Type::Time:
                exit(SymbolTable.TimeSymbol());
            Field.Type::DateTime:
                exit(SymbolTable.DateTimeSymbol());
            Field.Type::Guid:
                exit(SymbolTable.GuidSymbol());
            else
                Error('Accessing property "%1" of type %2 is not supported.', PropertyName, Field.Type);
        end;
    end;

    procedure TryLookupProperty
    (
        SymbolTable: Codeunit "Symbol Table FS";
        PropertyName: Text[120];
        var Symbol: Record "Symbol FS"
    ): Boolean
    var
        AllObj: Record AllObj;
        Field: Record Field;
    begin
        if Rec.Type <> Rec.Type::Record then
            exit(false);

        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        AllObj.SetRange("Object Name", Rec.Subtype);
        if not AllObj.FindFirst() then
            exit(false);

        Field.SetRange(TableNo, AllObj."Object ID");
        Field.SetRange(FieldName, PropertyName);
        if not Field.FindFirst() then
            exit(false);
        if not Field.Enabled then
            exit(false);
        if Field.ObsoleteState = Field.ObsoleteState::Removed then
            exit(false);

        case Field.Type of
            Field.Type::Integer,
            Field.Type::Decimal:
                Symbol := SymbolTable.NumericSymbol();
            Field.Type::Boolean:
                Symbol := SymbolTable.BooleanSymbol();
            Field.Type::Code,
            Field.Type::Text:
                Symbol := SymbolTable.TextSymbol();
            Field.Type::Date:
                Symbol := SymbolTable.DateSymbol();
            Field.Type::Time:
                Symbol := SymbolTable.TimeSymbol();
            Field.Type::DateTime:
                Symbol := SymbolTable.DateTimeSymbol();
            Field.Type::Guid:
                Symbol := SymbolTable.GuidSymbol();
            else
                exit(false);
        end;

        exit(true);
    end;
}

enum 69004 "Scope FS"
{
    Caption = 'Scope';

    value(1; "Local") { Caption = 'Local'; }
    value(2; "Parameter") { Caption = 'Parameter'; }
}