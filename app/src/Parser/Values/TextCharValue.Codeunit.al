codeunit 69112 "Text Char Value FS" implements "Value FS"
{
    var
        TextValue: Interface "Value FS";
        Index: Integer;

    procedure Init
    (
        NewTextValue: Interface "Value FS";
        NewIndex: Integer
    )
    begin
        TextValue := NewTextValue;
        Index := NewIndex;
    end;

    procedure GetValue(): Variant
    var
        Text: Text;
    begin
        Text := TextValue.GetValue();
        exit(Text[Index]);
    end;

    procedure SetValue(NewValue: Variant)
    var
        Text: Text;
    begin
        // TODO inefficient - instead modify the original text directly? (=new interface method?)
        Text := TextValue.GetValue();
        Text[Index] := NewValue;
        TextValue.SetValue(Text);
    end;

    procedure GetType(): Enum "Type FS"
    begin
        exit(Enum::"Type FS"::Char);
    end;

    procedure Copy(): Interface "Value FS"
    var
        CharValue: Codeunit "Char Value FS";
    begin
        CharValue.SetValue(GetValue());
        exit(CharValue);
    end;

    procedure Mutate(NewValue: Interface "Value FS")
    var
        Text: Text;
    begin
        // TODO inefficient - instead modify the original text directly? (=new interface method?)
        Text := TextValue.GetValue();
        Text[Index] := NewValue.GetValue();
        TextValue.SetValue(Text);
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS"
    begin
        Error('Char values do not support property access');
    end;

    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS")
    begin
        Error('Char values do not support property access');
    end;

    procedure Format(): Text;
    begin
        exit(System.Format(GetValue()));
    end;

    procedure Format(Length: Integer): Text;
    begin
        exit(System.Format(GetValue(), Length));
    end;

    procedure Format(Length: Integer; FormatNumber: Integer): Text;
    begin
        exit(System.Format(GetValue(), Length, FormatNumber));
    end;

    procedure Format(Length: Integer; FormatString: Text): Text;
    begin
        exit(System.Format(GetValue(), Length, FormatString));
    end;

    procedure Evaluate(Input: Text; Throw: Boolean): Boolean
    var
        Char: Char;
    begin
        if not Throw then begin
            if not System.Evaluate(Char, Input) then
                exit(false);

            SetValue(Char);
            exit(true);
        end;

        System.Evaluate(Char, Input);
        SetValue(Char);
        exit(true);
    end;

    procedure Evaluate(Input: Text; FormatNumber: Integer; Throw: Boolean): Boolean
    var
        Char: Char;
    begin
        if not Throw then begin
            if not System.Evaluate(Char, Input, FormatNumber) then
                exit(false);

            SetValue(Char);
            exit(true);
        end;

        System.Evaluate(Char, Input, FormatNumber);
        SetValue(Char);
        exit(true);
    end;

    procedure At(Self: Interface "Value FS"; IndexValue: Interface "Value FS"): Interface "Value FS"
    begin
        Error('Char values do not support index access.');
    end;
}