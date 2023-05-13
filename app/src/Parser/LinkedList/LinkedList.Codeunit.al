codeunit 69919 "Linked List FS"
{
    var
        FirstNode, LastNode : Codeunit "Linked List Node FS";
        Count: Integer;

    procedure First(var Node: Codeunit "Linked List Node FS"): Boolean
    begin
        if Count = 0 then
            exit(false);
        Node := FirstNode;
        exit(true);
    end;

    procedure Insert(Value: Interface "Node FS")
    var
        NewNode: Codeunit "Linked List Node FS";
    begin
        NewNode.Value(Value);

        if Count = 0 then begin
            FirstNode := NewNode;
            LastNode := FirstNode;
            Count += 1;
            exit;
        end;

        LastNode.SetNext(NewNode);
        LastNode := NewNode;
        Count += 1;
    end;
}