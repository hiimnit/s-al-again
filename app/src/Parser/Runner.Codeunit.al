codeunit 69002 "Runner FS"
{
    procedure Execute
    (
        Runtime: Codeunit "Runtime FS"
    )
    var
        EmptyValueLinkedList: Codeunit "Value Linked List FS";
        Function: Interface "Function FS";
    begin
        Runtime.ValidateFunctionsSemantics(Runtime);

        Function := Runtime.LookupEntryPoint();
        Function.Evaluate(Runtime, EmptyValueLinkedList, true);
    end;
}