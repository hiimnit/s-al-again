codeunit 69105 "Record Value FS" implements "Value FS"
{
    var
        Value: RecordRef;

    procedure Init
    (
        TableName: Text[120] // TODO change to id?
    )
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        AllObj.SetRange("Object Name", TableName);
        AllObj.FindFirst();

        Value.Open(AllObj."Object ID");
    end;

    procedure GetValue(): Variant;
    begin
        exit(Value);
    end;

    procedure SetValue(NewValue: Variant);
    begin
        Value := NewValue; // TODO here it might be a problem
        // TODO need to decide where SetValue will be used - values vs references
    end;

    procedure GetType(): Enum "Type FS"
    begin
        exit(Enum::"Type FS"::Record);
    end;

    procedure Copy(): Interface "Value FS"
    var
        RecordValue: Codeunit "Record Value FS";
    begin
        RecordValue.SetValue(CopyFieldValuesToNewRecordRef());
        exit(RecordValue);
    end;

    procedure Mutate(NewValue: Interface "Value FS");
    var
        FromRecordRef: RecordRef;
    begin
        // TODO test same number?
        FromRecordRef := NewValue.GetValue();
        CopyFieldValuesFromRecordRefToRecordRef(FromRecordRef, Value);
    end;

    local procedure CopyFieldValuesToNewRecordRef(): RecordRef
    var
        ToRecordRef: RecordRef;
    begin
        CopyFieldValuesFromRecordRefToRecordRef(Value, ToRecordRef);
        exit(ToRecordRef);
    end;

    local procedure CopyFieldValuesFromRecordRefToRecordRef(FromRecordRef: RecordRef; ToRecordRef: RecordRef)
    var
        i: Integer;
    begin
        if ToRecordRef.Number() = 0 then
            ToRecordRef.Open(FromRecordRef.Number());

        for i := 1 to FromRecordRef.FieldCount() do
            ToRecordRef.FieldIndex(i).Value := FromRecordRef.FieldIndex(i).Value();
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS"
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, Value.Number());
        Field.SetRange(FieldName, Name);
        Field.FindFirst(); // TODO duplicate

        exit(ValueFromVariant(
            Value.Field(Field."No.").Value()
        ));
    end;

    local procedure ValueFromVariant(Variant: Variant): Interface "Value FS";
    var
        NumericValue: Codeunit "Numeric Value FS";
        BooleanValue: Codeunit "Boolean Value FS";
        TextValue: Codeunit "Text Value FS";
        DateValue: Codeunit "Date Value FS";
        TimeValue: Codeunit "Time Value FS";
        DateTimeValue: Codeunit "DateTime Value FS";
        GuidValue: Codeunit "Guid Value FS";
    begin
        case true of
            Variant.IsInteger(),
            Variant.IsDecimal():
                begin
                    NumericValue.SetValue(Variant);
                    exit(NumericValue);
                end;
            Variant.IsBoolean():
                begin
                    BooleanValue.SetValue(Variant);
                    exit(BooleanValue);
                end;
            Variant.IsCode(),
            Variant.IsText():
                begin
                    TextValue.SetValue(Variant);
                    exit(TextValue);
                end;
            Variant.IsDate():
                begin
                    DateValue.SetValue(Variant);
                    exit(DateValue);
                end;
            Variant.IsTime():
                begin
                    TimeValue.SetValue(Variant);
                    exit(TimeValue);
                end;
            Variant.IsDateTime():
                begin
                    DateTimeValue.SetValue(Variant);
                    exit(DateTimeValue);
                end;
            Variant.IsGuid():
                begin
                    GuidValue.SetValue(Variant);
                    exit(GuidValue);
                end;
            else
                Error('Initilization of type from value %1 is not supported.', Value);
        end;
    end;

    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS")
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, Value.Number());
        Field.SetRange(FieldName, Name);
        Field.FindFirst(); // TODO duplicate

        Value.Field(Field."No.").Value(NewValue.GetValue())
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