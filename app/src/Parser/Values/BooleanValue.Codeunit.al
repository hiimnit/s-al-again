codeunit 69102 "Boolean Value FS" implements "Value FS"
{
    var
        Value: Boolean;

    procedure GetValue(): Variant;
    begin
        exit(Value);
    end;

    procedure SetValue(NewValue: Variant);
    begin
        Value := NewValue;
    end;

    procedure GetType(): Enum "Type FS"
    begin
        exit(Enum::"Type FS"::Boolean);
    end;
}