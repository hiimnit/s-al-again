codeunit 69116 "Option Value FS" implements "Value FS"
{
    var
        Value: Integer;
        Members: Text;
        Captions: Text;

    procedure Init
    (
        NewMembers: Text;
        NewCaptions: Text
    )
    begin
        Members := NewMembers;
        Captions := NewCaptions;
    end;

    procedure GetValue(): Variant;
    begin
        exit(Value);
    end;

    procedure SetValue(NewValue: Variant);
    begin
        Value := NewValue;
    end;

    procedure Copy(): Interface "Value FS"
    var
        IntegerValue: Codeunit "Integer Value FS";
    begin
        IntegerValue.SetValue(Value);
        exit(IntegerValue);
    end;

    procedure Mutate(NewValue: Interface "Value FS");
    begin
        Value := NewValue.GetValue();
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS";
    begin
        Error('Option values do not support property access');
    end;

    procedure Format(): Text;
    begin
        exit(Format(0, 0));
    end;

    procedure Format(Length: Integer): Text;
    begin
        exit(Format(0, 0));
    end;

    procedure Format(Length: Integer; FormatNumber: Integer): Text;
    var
        FormattedText: Text;
    begin
        case FormatNumber of
            0, 1:
                if not TrySelectStr(Value, Captions, FormattedText) then
                    FormattedText := System.Format(Value);
            2, 9:
                FormattedText := System.Format(Value);
            else
                Error('Standard format number %1 does not exist for the type ''Option''.', FormatNumber);
        end;

        if Length = 0 then
            exit(FormattedText);
        exit(System.Format(FormattedText, Length));
    end;

    procedure Format(Length: Integer; FormatString: Text): Text;
    var
        FormattedText: Text;
    begin
        case FormatString.ToLower() of
            '<text>':
                if not TrySelectStr(Value, Captions, FormattedText) then
                    FormattedText := System.Format(Value);
            '<number>':
                FormattedText := System.Format(Value);
            else
                Error('An invalid field or attribute has been specified for the ''Format'' property.\\%1', FormatString);
        end;

        if Length = 0 then
            exit(FormattedText);
        exit(System.Format(FormattedText, Length));
    end;

    [TryFunction]
    local procedure TrySelectStr(Number: Integer; CommaString: Text; var Result: Text)
    begin
        Result := SelectStr(Number, CommaString);
    end;

    procedure Evaluate(Input: Text; Throw: Boolean): Boolean
    var
        Result: Integer;
    begin
        Result := 0;
        if not Evaluate(Input, Result) then begin
            if Throw then
                Error('''%1'' is not an option. The existing options are: ''%2''', Input, Members);
            exit(false);
        end;

        Value := Result;
        exit(true);
    end;

    procedure Evaluate(Input: Text; FormatNumber: Integer; Throw: Boolean): Boolean
    begin
        // looks like FormatNumber is ignored?
        exit(Evaluate(Input, Throw));
    end;

    local procedure Evaluate(Input: Text; var Result: Integer): Boolean
    begin
        Result := Captions.ToLower().Split(',').IndexOf(Input.ToLower()) - 1;
        if Result >= 0 then
            exit(true);

        Result := Members.ToLower().Split(',').IndexOf(Input.ToLower()) - 1;
        if Result >= 0 then
            exit(true);

        if System.Evaluate(Result, Input) then
            exit(true);

        exit(false);
    end;

    procedure At(Self: Interface "Value FS"; Index: Interface "Value FS"): Interface "Value FS"
    begin
        Error('Option values do not support index access.');
    end;
}