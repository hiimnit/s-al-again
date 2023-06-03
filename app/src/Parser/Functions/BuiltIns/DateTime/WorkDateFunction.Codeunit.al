codeunit 69209 "WorkDate Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('WorkDate');
    end;

    procedure GetReturnType(TopLevel: Boolean): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.DateSymbol());
    end;

    procedure ValidateCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Arguments: Codeunit "Node Linked List FS"
    )
    var
        ParameterSymbol: Record "Symbol FS";
    begin
        if Arguments.GetCount() > 0 then
            ParameterSymbol.InsertDate('WorkDate', 1);

        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS"
    var
        Value: Codeunit "Value Linked List Node FS";
        DateValue: Codeunit "Date Value FS";
    begin
        if not ValueLinkedList.First(Value) then begin
            DateValue.SetValue(WorkDate());

            exit(DateValue);
        end;

        DateValue.SetValue(WorkDate(Value.Value().GetValue()));

        exit(DateValue);
    end;
}