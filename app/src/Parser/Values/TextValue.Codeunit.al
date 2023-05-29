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

    procedure Mutate(NewValue: Interface "Value FS");
    begin
        Value := NewValue.GetValue();
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS";
    begin
        Error('Text values do not support property access');
    end;

    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS");
    begin
        Error('Text values do not support property access');
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