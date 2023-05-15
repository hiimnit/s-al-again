codeunit 69016 "Statement List FS" implements "Node FS"
{
    var
        StatementsList: Codeunit "Node Linked List FS";

    procedure Add(Statement: Interface "Node FS")
    begin
        StatementsList.Insert(Statement);
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        LinkedListNode: Codeunit "Node Linked List Node FS";
    begin
        if StatementsList.First(LinkedListNode) then
            repeat
                LinkedListNode.Value().Evaluate(Runtime);
            until not LinkedListNode.Next(LinkedListNode);
        exit(VoidValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        LinkedListNode: Codeunit "Node Linked List Node FS";
    begin
        if StatementsList.First(LinkedListNode) then
            repeat
                LinkedListNode.Value().ValidateSemantics(Runtime, SymbolTable);
            until not LinkedListNode.Next(LinkedListNode);

        exit(SymbolTable.VoidSymbol());
    end;
}