codeunit 69104 "Return Value FS" implements "Value FS"
{
    var
        Value: Interface "Value FS";
        ValueSet: Boolean;

    procedure Init
    (
        NewValue: Interface "Value FS"
    )
    begin
        Value := NewValue;
        ValueSet := true;
    end;

    procedure GetValue(): Variant;
    begin
        // TODO unused?
        exit(Value.GetValue());
    end;

    procedure SetValue(NewValue: Variant);
    begin
        Error('Cannot set value of return value.');
    end;

    procedure GetType(): Enum "Type FS"
    begin
        if not ValueSet then
            exit(Enum::"Type FS"::"Default Return Value");
        exit(Enum::"Type FS"::"Return Value");
    end;

    procedure Copy(): Interface "Value FS"
    begin
        exit(Value.Copy());
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS";
    begin
        Error('Return values do not support property access');
    end;

    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS");
    begin
        Error('Return values do not support property access');
    end;

    procedure Format(): Text;
    begin
        Error('Return values can not be formatted.');
    end;

    procedure Format(Length: Integer): Text;
    begin
        Error('Return values can not be formatted.');
    end;

    procedure Format(Length: Integer; FormatNumber: Integer): Text;
    begin
        Error('Return values can not be formatted.');
    end;

    procedure Format(Length: Integer; FormatString: Text): Text;
    begin
        Error('Return values can not be formatted.');
    end;
}