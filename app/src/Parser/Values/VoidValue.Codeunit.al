codeunit 69100 "Void Value FS" implements "Value FS"
{
    SingleInstance = true;

    procedure GetValue(): Variant;
    begin
        Error('Cannot get value of void.');
    end;

    procedure SetValue(NewValue: Variant);
    begin
        Error('Cannot set value of void.');
    end;

    procedure GetType(): Enum "Type FS"
    begin
        exit(Enum::"Type FS"::Void);
    end;
}