codeunit 69016 "Statement List FS" implements "Node FS"
{
    var
        StatementsList: Codeunit "Linked List FS";

    procedure Add(Statement: Interface "Node FS")
    begin
        StatementsList.Insert(Statement);
    end;

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        LinkedListNode: Codeunit "Linked List Node FS";
    begin
        if StatementsList.First(LinkedListNode) then
            repeat
                LinkedListNode.Value().Evaluate(Memory);
            until not LinkedListNode.Next(LinkedListNode);
        exit(VoidValue);
    end;

    procedure ValidateSemantics(SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        LinkedListNode: Codeunit "Linked List Node FS";
    begin
        if StatementsList.First(LinkedListNode) then
            repeat
                LinkedListNode.Value().ValidateSemantics(SymbolTable);
            until not LinkedListNode.Next(LinkedListNode);

        exit(SymbolTable.VoidSymbol());
    end;
}