codeunit 69103 "Text Value FS" implements "Value FS"
{
    var
        Value: Text;

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
        exit(Enum::"Type FS"::Text);
    end;

    procedure Copy(): Interface "Value FS"
    var
        TextValue: Codeunit "Text Value FS";
    begin
        TextValue.SetValue(Value);
        exit(TextValue);
    end;
}