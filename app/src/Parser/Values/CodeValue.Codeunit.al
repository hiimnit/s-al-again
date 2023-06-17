codeunit 69104 "Code Value FS" implements "Value FS"
{
    var
        MaxLength: Integer;
        MaxLengthDefined: Boolean;

    procedure SetMaxLength(NewMaxLength: Integer)
    begin
        MaxLength := NewMaxLength;
        MaxLengthDefined := true;
    end;

    var
        Value: Text;

    procedure GetValue(): Variant;
    begin
        exit(Value);
    end;

    procedure SetValue(NewValue: Variant)
    begin
        if MaxLengthDefined and (StrLen(NewValue) > MaxLength) then
            Error(
                'The length of the string is %1, but it must be less than or equal to %2 characters. Value: %3.',
                StrLen(NewValue),
                MaxLength,
                NewValue
            );

        Value := NewValue;
        Value := Value.ToUpper();
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
        SetValue(NewValue.GetValue());
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS";
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

    procedure Evaluate(Input: Text; Throw: Boolean): Boolean
    begin
        if not Throw then
            exit(System.Evaluate(Value, Input));

        System.Evaluate(Value, Input);
        exit(true);
    end;

    procedure Evaluate(Input: Text; FormatNumber: Integer; Throw: Boolean): Boolean
    begin
        if not Throw then
            exit(System.Evaluate(Value, Input, FormatNumber));

        System.Evaluate(Value, Input, FormatNumber);
        exit(true);
    end;

    procedure At(Self: Interface "Value FS"; Index: Interface "Value FS"): Interface "Value FS"
    var
        TextCharValue: Codeunit "Text Char Value FS";
    begin
        TextCharValue.Init(
            Self,
            Index.GetValue()
        );
        exit(TextCharValue);
    end;
}