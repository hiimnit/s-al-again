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

    procedure Copy(): Interface "Value FS"
    var
        BooleanValue: Codeunit "Boolean Value FS";
    begin
        BooleanValue.SetValue(Value);
        exit(BooleanValue);
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS";
    begin
        Error('Boolean values do not support property access');
    end;

    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS");
    begin
        Error('Boolean values do not support property access');
    end;
}