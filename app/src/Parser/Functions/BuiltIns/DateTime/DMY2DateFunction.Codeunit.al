codeunit 69216 "DMY2Date Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('DMY2Date');
    end;

    procedure GetReturnType(): Record "Symbol FS"
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
        ParameterSymbol.InsertNumber('Day', 1);
        if Arguments.GetCount() > 1 then
            ParameterSymbol.InsertNumber('Month', 2);
        if Arguments.GetCount() > 2 then
            ParameterSymbol.InsertNumber('Year', 3);

        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    var
        NumericValue: Codeunit "Numeric Value FS";
        ValueNode: Codeunit "Value Linked List Node FS";
        Day, Month, Year : Interface "Value FS";
    begin
        ValueNode := ValueLinkedList.First();
        Day := ValueNode.Value();

        if not ValueNode.HasNext() then begin
            NumericValue.SetValue(DMY2Date(
                Day.GetValue()
            ));

            exit(NumericValue);
        end;

        ValueNode := ValueNode.Next();
        Month := ValueNode.Value();

        if not ValueNode.HasNext() then begin
            NumericValue.SetValue(DMY2Date(
                Day.GetValue(),
                Month.GetValue()
            ));

            exit(NumericValue);
        end;

        ValueNode := ValueNode.Next();
        Year := ValueNode.Value();

        NumericValue.SetValue(DMY2Date(
            Day.GetValue(),
            Month.GetValue(),
            Year.GetValue()
        ));

        exit(NumericValue);
    end;
}