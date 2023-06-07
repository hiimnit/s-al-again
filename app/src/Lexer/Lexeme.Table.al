table 69000 "Lexeme FS"
{
    Caption = 'Lexeme';
    DataClassification = CustomerContent;
    TableType = Temporary;
    LookupPageId = "Lexemes FS";
    DrillDownPageId = "Lexemes FS";

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; Type; Enum "Lexeme Type FS") { }

        field(1000; "Keyword Value"; Enum "Keyword FS") { }

        field(2000; "Operator Value"; Enum "Operator FS") { }

        field(4000; "Identifier Name"; Text[120]) { }

        field(5000; "Number Value"; Decimal) { }

        field(6000; "Boolean Value"; Boolean) { }

        field(7000; "String Value"; Text[250]) { }
        field(7001; "String Value Blob"; Blob) { }
        field(8000; "Char Value"; Text[1]) { }

        field(10000; "Date Value"; Date) { }
        field(11000; "Time Value"; Time) { }
        field(12000; "DateTime Value"; DateTime) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }

    procedure EOS(): Record "Lexeme FS"
    begin
        Rec.Init();
        Rec.Type := Rec.Type::EOS;
        exit(Rec);
    end;

    procedure Number(Value: Decimal): Record "Lexeme FS"
    begin
        Rec.Init();
        Rec.Type := Rec.Type::Number;
        Rec."Number Value" := Value;
        exit(Rec);
    end;

    procedure Bool(Value: Boolean): Record "Lexeme FS"
    begin
        Rec.Init();
        Rec.Type := Rec.Type::Bool;
        Rec."Boolean Value" := Value;
        exit(Rec);
    end;

    procedure Date(Value: Date): Record "Lexeme FS"
    begin
        Rec.Init();
        Rec.Type := Rec.Type::Date;
        Rec."Date Value" := Value;
        exit(Rec);
    end;

    procedure Time(Value: Time): Record "Lexeme FS"
    begin
        Rec.Init();
        Rec.Type := Rec.Type::Time;
        Rec."Time Value" := Value;
        exit(Rec);
    end;

    procedure DateTime(DateValue: Date; TimeValue: Time): Record "Lexeme FS"
    begin
        Rec.Init();
        Rec.Type := Rec.Type::DateTime;
        Rec."DateTime Value" := CreateDateTime(DateValue, TimeValue);
        exit(Rec);
    end;

    procedure Identifier(): Record "Lexeme FS"
    begin
        Rec.Init();
        Rec.Type := Rec.Type::Identifier;
        exit(Rec);
    end;

    procedure Identifier(Name: Text): Record "Lexeme FS"
    begin
        if StrLen(Name) > MaxStrLen(Rec."Identifier Name") then
            Error('Identifier name >%1< exceeds maximum allowed length of %2.', Name, MaxStrLen(Rec."Identifier Name"));

        Rec.Init();
        Rec.Type := Rec.Type::Identifier;
        Rec."Identifier Name" := Name;
        exit(Rec);
    end;

    procedure Keyword(Value: Enum "Keyword FS"): Record "Lexeme FS"
    begin
        Rec.Init();
        Rec.Type := Rec.Type::Keyword;
        Rec."Keyword Value" := Value;
        exit(Rec);
    end;

    procedure Operator(Value: Enum "Operator FS"): Record "Lexeme FS"
    begin
        Rec.Init();
        Rec.Type := Rec.Type::Operator;
        Rec."Operator Value" := Value;
        exit(Rec);
    end;

    procedure StringLiteral(Value: Text): Record "Lexeme FS"
    begin
        Rec.Init();
        Rec.Type := Rec.Type::String;
        SetStringValue(Value);
        exit(Rec);
    end;

    procedure CharLiteral(Value: Text): Record "Lexeme FS"
    begin
        Rec.Init();
        Rec.Type := Rec.Type::Char;
        Rec."Char Value" := Value;
        exit(Rec);
    end;

    local procedure SetStringValue(Value: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Rec."String Value Blob");
        if StrLen(Value) <= MaxStrLen(Rec."String Value") then begin
            Rec."String Value" := Value;
            exit;
        end;

        Rec."String Value Blob".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(Value);
    end;

    procedure GetStringValue(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        if not Rec."String Value Blob".HasValue() then
            exit(Rec."String Value");

        Rec."String Value Blob".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(
            InStream,
            TypeHelper.LFSeparator()
        ));
    end;

    procedure GetValue(): Text
    begin
        case Rec.Type of
            Rec.Type::EOS:
                exit('');
            Rec.Type::Bool:
                exit(Format(Rec."Boolean Value"));
            Rec.Type::Identifier:
                exit(Rec."Identifier Name");
            Rec.Type::Keyword:
                exit(Format(Rec."Keyword Value"));
            Rec.Type::Operator:
                exit(Format(Rec."Operator Value"));
            Rec.Type::Number:
                exit(Format(Rec."Number Value", 0, 9));
            Rec.Type::String:
                exit(Rec.GetStringValue());
            else
                Rec.FieldError(Type);
        end;
    end;

    procedure IsKeyword(ExpectedKeyword: Enum "Keyword FS"): Boolean
    begin
        if Rec.Type <> Rec.Type::Keyword then
            exit(false);
        exit(Rec."Keyword Value" = ExpectedKeyword);
    end;

    procedure IsOperator(): Boolean
    begin
        exit(Rec.Type = Rec.Type::Operator);
    end;

    procedure IsOperator(ExpectedOperator: Enum "Operator FS"): Boolean
    begin
        if not Rec.IsOperator() then
            exit(false);
        exit(Rec."Operator Value" = ExpectedOperator);
    end;

    procedure IsIdentifier(): Boolean
    begin
        exit(Rec.Type = Rec.Type::Identifier);
    end;

    procedure IsNumber(): Boolean
    begin
        exit(Rec.Type = Rec.Type::Number);
    end;

    procedure IsBoolean(): Boolean
    begin
        exit(Rec.Type = Rec.Type::Bool);
    end;

    procedure IsString(): Boolean
    begin
        exit(Rec.Type = Rec.Type::String);
    end;

    procedure IsChar(): Boolean
    begin
        exit(Rec.Type = Rec.Type::Char);
    end;

    procedure IsDate(): Boolean
    begin
        exit(Rec.Type = Rec.Type::Date);
    end;

    procedure IsTime(): Boolean
    begin
        exit(Rec.Type = Rec.Type::Time);
    end;

    procedure IsDateTime(): Boolean
    begin
        exit(Rec.Type = Rec.Type::DateTime);
    end;

    procedure IsLiteralValue(): Boolean
    begin
        exit(true in [
            IsNumber(),
            IsBoolean(),
            IsString(),
            IsDate(),
            IsTime(),
            IsDateTime()
        ]);
    end;

    procedure IsAssignmentOperator(): Boolean
    begin
        if not Rec.IsOperator() then
            exit(false);

        exit(Rec."Operator Value" in [
            Enum::"Operator FS"::":=",
            Enum::"Operator FS"::"+=",
            Enum::"Operator FS"::"-=",
            Enum::"Operator FS"::"*=",
            Enum::"Operator FS"::"/="
        ]);
    end;

    procedure IsEOS(): Boolean
    begin
        exit(Rec.Type = Rec.Type::EOS);
    end;
}