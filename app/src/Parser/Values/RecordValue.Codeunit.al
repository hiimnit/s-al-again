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
    begin
        Error('Unimplemented error.');
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS"
    var
        Field: Record Field;
        Memory: Codeunit "Memory FS";
    begin
        Field.SetRange(TableNo, Value.Number());
        Field.SetRange(FieldName, Name);
        Field.FindFirst(); // TODO duplicate

        exit(Memory.ValueFromVariant(
            Value.Field(Field."No.").Value()
        ));
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
}