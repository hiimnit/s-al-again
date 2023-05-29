codeunit 69010 "Literal Value Node FS" implements "Node FS"
{
    var
        LiteralValue: Interface "Value FS";

    procedure Init(Value: Decimal)
    var
        NumericValue: Codeunit "Numeric Value FS";
    begin
        NumericValue.SetValue(Value);
        LiteralValue := NumericValue;
    end;

    procedure Init(Value: Boolean)
    var
        BooleanValue: Codeunit "Boolean Value FS";
    begin
        BooleanValue.SetValue(Value);
        LiteralValue := BooleanValue;
    end;

    procedure Init(Value: Text)
    var
        TextValue: Codeunit "Text Value FS";
    begin
        TextValue.SetValue(Value);
        LiteralValue := TextValue;
    end;

    procedure Init(Value: Date)
    var
        DateValue: Codeunit "Date Value FS";
    begin
        DateValue.SetValue(Value);
        LiteralValue := DateValue;
    end;

    procedure Init(Value: Time)
    var
        TimeValue: Codeunit "Time Value FS";
    begin
        TimeValue.SetValue(Value);
        LiteralValue := TimeValue;
    end;

    procedure Init(Value: DateTime)
    var
        DateTimeValue: Codeunit "DateTime Value FS";
    begin
        DateTimeValue.SetValue(Value);
        LiteralValue := DateTimeValue;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Literal Value");
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
        exit(SymbolTable.SymbolFromType(LiteralValue.GetType()));
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