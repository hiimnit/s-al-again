codeunit 69213 "CalcDate Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('CalcDate');
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
        ParameterSymbol.InsertText('Text', 1);
        if Arguments.GetCount() > 1 then
            ParameterSymbol.InsertDate('Date', 2);

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
        DateValue: Codeunit "Date Value FS";
        ValueNode: Codeunit "Value Linked List Node FS";
        Text: Text;
        Date: Interface "Value FS";
    begin
        ValueNode := ValueLinkedList.First();
        Text := ValueNode.Value().GetValue();

        if not ValueNode.HasNext() then begin
            DateValue.SetValue(CalcDate(Text));

            exit(DateValue);
        end;

        ValueNode := ValueNode.Next();
        Date := ValueNode.Value();

        DateValue.SetValue(CalcDate(Text, Date.GetValue()));

        exit(DateValue);
    end;
}