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

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    begin
        exit(LiteralValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    begin
        exit(SymbolTable.SymbolFromType(LiteralValue.GetType()));
    end;
}