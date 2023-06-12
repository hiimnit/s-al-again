codeunit 69217 "DWY2Date Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('DWY2Date');
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
        ParameterSymbol.InsertInteger('WeekDay', 1);
        if Arguments.GetCount() > 1 then
            ParameterSymbol.InsertInteger('Week', 2);
        if Arguments.GetCount() > 2 then
            ParameterSymbol.InsertInteger('Year', 3);

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
        DateValue: Codeunit "Date Value FS";
        ValueNode: Codeunit "Value Linked List Node FS";
        Day, Month, Year : Interface "Value FS";
    begin
        ValueNode := ValueLinkedList.First();
        Day := ValueNode.Value();

        if not ValueNode.HasNext() then begin
            DateValue.SetValue(DWY2Date(
                Day.GetValue()
            ));

            exit(DateValue);
        end;

        ValueNode := ValueNode.Next();
        Month := ValueNode.Value();

        if not ValueNode.HasNext() then begin
            DateValue.SetValue(DWY2Date(
                Day.GetValue(),
                Month.GetValue()
            ));

            exit(DateValue);
        end;

        ValueNode := ValueNode.Next();
        Year := ValueNode.Value();

        DateValue.SetValue(DWY2Date(
            Day.GetValue(),
            Month.GetValue(),
            Year.GetValue()
        ));

        exit(DateValue);
    end;
}