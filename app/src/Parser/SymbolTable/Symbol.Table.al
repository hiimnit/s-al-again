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
        field(40; Length; Integer)
        {
            Caption = 'Length';
        }
        field(41; "Length Defined"; Boolean)
        {
            Caption = 'Length Defined';
        }
    }

    keys
    {
        key(PK; Name) { Clustered = true; }
        key(Order; Order) { }
    }

    procedure InsertInteger
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Integer,
            NewOrder,
            false
        );
    end;

    procedure InsertDecimal
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Decimal,
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

    procedure InsertChar
    (
        NewName: Text[120];
        NewOrder: Integer
    )
    begin
        InsertParameter(
            NewName,
            Rec.Type::Char,
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

    procedure SetLength(NewLength: Integer)
    begin
        Rec.Length := NewLength;
        Rec."Length Defined" := true;
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

        if Rec."Length Defined" then begin
            if not (Rec.Type in [
                Rec.Type::Text,
                Rec.Type::Code
            ]) then
                Error('Length can only be defined for %1 and %2.', Rec.Type::Text, Rec.Type::Code);

            if Rec.Length < 1 then
                Error('Length must be positive.');
        end;
    end;

    procedure TryLookupSubtype(): Integer
    var
        AllObj: Record AllObj;
    begin
        case Rec.Type of
            Rec.Type::Record:
                begin
                    if Rec.Subtype = '' then
                        exit(-1);
                    AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
                    AllObj.SetRange("Object Name", Rec.Subtype);
                    if not AllObj.FindFirst() then
                        exit(-1);
                    exit(AllObj."Object ID");
                end;
        end;

        exit(-1);
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
                exit(Target.Type in [Target.Type::Code, Target.Type::Guid]);
            Rec.Type::Code:
                exit(Target.Type in [Target.Type::Text, Target.Type::Guid]);
            Rec.Type::Guid:
                exit(Target.Type in [Target.Type::Text, Target.Type::Code]);
            Rec.Type::Char:
                exit(Target.Type in [Target.Type::Text, Target.Type::Code, Target.Type::Integer, Target.Type::Decimal]);
            Rec.Type::Integer:
                exit(Target.Type in [Target.Type::Char, Target.Type::Decimal]);
            Rec.Type::Decimal:
                exit(Target.Type in [Target.Type::Char, Target.Type::Integer]);
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
        Symbol: Record "Symbol FS";
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
            Field.Type::Integer:
                exit(SymbolTable.IntegerSymbol());
            Field.Type::Decimal:
                exit(SymbolTable.DecimalSymbol());
            Field.Type::Boolean:
                exit(SymbolTable.BooleanSymbol());
            Field.Type::Text:
                begin
                    Symbol := SymbolTable.TextSymbol();
                    Symbol.SetLength(Field.Len);
                    exit(Symbol);
                end;
            Field.Type::Code:
                begin
                    Symbol := SymbolTable.CodeSymbol();
                    Symbol.SetLength(Field.Len);
                    exit(Symbol);
                end;
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
            Field.Type::Integer:
                Symbol := SymbolTable.IntegerSymbol();
            Field.Type::Decimal:
                Symbol := SymbolTable.DecimalSymbol();
            Field.Type::Boolean:
                Symbol := SymbolTable.BooleanSymbol();
            Field.Type::Text:
                begin
                    Symbol := SymbolTable.TextSymbol();
                    Symbol.SetLength(Field.Len);
                end;
            Field.Type::Code:
                begin
                    Symbol := SymbolTable.CodeSymbol();
                    Symbol.SetLength(Field.Len);
                end;
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

    procedure ValidateIndexAcces
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        ValueSymbol: Record "Symbol FS";
        IndexSymbol: Record "Symbol FS"
    ): Record "Symbol FS"
    var
        ResultSymbol: Record "Symbol FS";
    begin
        case ValueSymbol.Type of
            ValueSymbol.Type::Code,
            ValueSymbol.Type::Text:
                begin
                    if not Runtime.MatchTypesCoercible(
                        SymbolTable.IntegerSymbol(),
                        IndexSymbol
                    ) then
                        Error(
                            'Type %1 can not be used to index %2 value.',
                            IndexSymbol.TypeToText(),
                            ValueSymbol.TypeToText()
                        );

                    ResultSymbol := SymbolTable.CharSymbol();
                end;
            else
                Error('Type %1 does not support index access.', ValueSymbol.TypeToText());
        end;

        exit(ResultSymbol);
    end;

    procedure ToJson(): JsonObject
    var
        Symbol: JsonObject;
    begin
        Symbol.Add('name', Rec.Name);
        Symbol.Add('type', Format(Rec.Type));
        if Rec.Subtype <> '' then
            Symbol.Add('sybtype', Rec.Subtype);
        if Rec."Length Defined" then
            Symbol.Add('length', Format(Rec.Length));
        Symbol.Add('scope', Format(Rec.Scope));
        Symbol.Add('pointer', Rec."Pointer Parameter");

        exit(Symbol);
    end;
}

enum 69004 "Scope FS"
{
    Caption = 'Scope';

    value(1; "Local") { Caption = 'Local'; }
    value(2; "Parameter") { Caption = 'Parameter'; }
}