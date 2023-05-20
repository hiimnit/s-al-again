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

    procedure GetProperty(Name: Text[120]): Interface "Value FS";
    begin
        Error('Text values do not support property access');
    end;

    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS");
    begin
        Error('Text values do not support property access');
    end;
}