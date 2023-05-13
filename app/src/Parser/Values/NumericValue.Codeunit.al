codeunit 69101 "Numeric Value FS" implements "Value FS"
{
    var
        Value: Decimal;

    procedure GetValue(): Variant;
    begin
        exit(Value);
    end;

    procedure SetValue(NewValue: Variant);
    begin
        // TODO runtime data type checking?
        Value := NewValue;
    end;

    procedure GetType(): Enum "Type FS"
    begin
        exit(Enum::"Type FS"::Number);
    end;
}