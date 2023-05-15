codeunit 69919 "Node Linked List FS"
{
    var
        FirstNode, LastNode : Codeunit "Node Linked List Node FS";
        Count: Integer;

    procedure First(var Node: Codeunit "Node Linked List Node FS"): Boolean
    begin
        if Count = 0 then
            exit(false);
        Node := FirstNode;
        exit(true);
    end;

    procedure Insert(Value: Interface "Node FS")
    var
        NewNode: Codeunit "Node Linked List Node FS";
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
