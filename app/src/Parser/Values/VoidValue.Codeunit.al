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

    procedure Copy(): Interface "Value FS"
    var
        VoidValue: Codeunit "Void Value FS";
    begin
        exit(VoidValue);
    end;

    procedure Mutate(NewValue: Interface "Value FS");
    begin
        Error('Void values can not be mutated.');
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS";
    begin
        Error('Void values do not support property access');
    end;

    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS");
    begin
        Error('Void values do not support property access');
    end;

    procedure Format(): Text;
    begin
        Error('Void values can not be formatted.');
    end;

    procedure Format(Length: Integer): Text;
    begin
        Error('Void values can not be formatted.');
    end;

    procedure Format(Length: Integer; FormatNumber: Integer): Text;
    begin
        Error('Void values can not be formatted.');
    end;

    procedure Format(Length: Integer; FormatString: Text): Text;
    begin
        Error('Void values can not be formatted.');
    end;

    procedure Evaluate(Input: Text; Throw: Boolean): Boolean
    begin
        Error('Void values can not be evaluated.');
    end;

    procedure Evaluate(Input: Text; FormatNumber: Integer; Throw: Boolean): Boolean
    begin
        Error('Void values can not be evaluated.');
    end;

    procedure At(Self: Interface "Value FS"; Index: Interface "Value FS"): Interface "Value FS"
    begin
        Error('Void values do not support index access.');
    end;
}