codeunit 69109 "Guid Value FS" implements "Value FS"
{
    var
        Value: Guid;

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
        exit(Enum::"Type FS"::Guid);
    end;

    procedure Copy(): Interface "Value FS"
    var
        GuidValue: Codeunit "Guid Value FS";
    begin
        GuidValue.SetValue(Value);
        exit(GuidValue);
    end;

    procedure Mutate(NewValue: Interface "Value FS");
    begin
        Value := NewValue.GetValue();
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS";
    begin
        Error('Guid values do not support property access');
    end;

    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS");
    begin
        Error('Guid values do not support property access');
    end;

    procedure Format(): Text;
    begin
        exit(System.Format(Value));
    end;

    procedure Format(Length: Integer): Text;
    begin
        exit(System.Format(Value, Length));
    end;

    procedure Format(Length: Integer; FormatNumber: Integer): Text;
    begin
        exit(System.Format(Value, Length, FormatNumber));
    end;

    procedure Format(Length: Integer; FormatString: Text): Text;
    begin
        exit(System.Format(Value, Length, FormatString));
    end;
}