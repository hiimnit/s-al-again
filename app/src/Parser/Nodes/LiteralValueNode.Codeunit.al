codeunit 69010 "Literal Value Node FS" implements "Node FS"
{
    var
        LiteralValue: Interface "Value FS";
        Type: Enum "Type FS";

    procedure Init(Value: Integer)
    var
        IntegerValue: Codeunit "Integer Value FS";
    begin
        IntegerValue.SetValue(Value);
        LiteralValue := IntegerValue;
        Type := Type::Integer;
    end;

    procedure Init(Value: Decimal)
    var
        DecimalValue: Codeunit "Decimal Value FS";
    begin
        DecimalValue.SetValue(Value);
        LiteralValue := DecimalValue;
        Type := Type::Decimal;
    end;

    procedure Init(Value: Boolean)
    var
        BooleanValue: Codeunit "Boolean Value FS";
    begin
        BooleanValue.SetValue(Value);
        LiteralValue := BooleanValue;
        Type := Type::Boolean;
    end;

    procedure Init(Value: Text)
    var
        TextValue: Codeunit "Text Value FS";
    begin
        TextValue.SetValue(Value);
        LiteralValue := TextValue;
        Type := Type::Text;
    end;

    procedure Init(Value: Char)
    var
        CharValue: Codeunit "Char Value FS";
    begin
        CharValue.SetValue(Value);
        LiteralValue := CharValue;
        Type := Type::Char;
    end;

    procedure Init(Value: Date)
    var
        DateValue: Codeunit "Date Value FS";
    begin
        DateValue.SetValue(Value);
        LiteralValue := DateValue;
        Type := Type::Date;
    end;

    procedure Init(Value: Time)
    var
        TimeValue: Codeunit "Time Value FS";
    begin
        TimeValue.SetValue(Value);
        LiteralValue := TimeValue;
        Type := Type::Time;
    end;

    procedure Init(Value: DateTime)
    var
        DateTimeValue: Codeunit "DateTime Value FS";
    begin
        DateTimeValue.SetValue(Value);
        LiteralValue := DateTimeValue;
        Type := Type::DateTime;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Literal Value");
    end;

    procedure Assignable(): Boolean
    begin
        exit(false);
    end;

    procedure IsLiteralValue(): Boolean
    begin
        exit(true);
    end;

    var
        TopLevel: Boolean;

    procedure SetTopLevel(NewTopLevel: Boolean)
    begin
        TopLevel := NewTopLevel;
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    begin
        exit(LiteralValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    begin
        exit(SymbolTable.SymbolFromType(Type));
    end;

    procedure ValidateSemanticsWithContext
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        ContextSymbol: Record "Symbol FS"
    ): Record "Symbol FS";
    begin
        exit(ValidateSemantics(
            Runtime,
            SymbolTable
        ));
    end;
}