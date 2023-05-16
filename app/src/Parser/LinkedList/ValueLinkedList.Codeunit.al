codeunit 69921 "Value Linked List FS"
{
    var
        FirstNode, LastNode : Codeunit "Value Linked List Node FS";
        Count: Integer;

    procedure First(var Node: Codeunit "Value Linked List Node FS"): Boolean
    begin
        if Count = 0 then
            exit(false);
        Node := FirstNode;
        exit(true);
    end;

    procedure First(): Codeunit "Value Linked List Node FS"
    begin
        if Count = 0 then
            Error('Out of bounds, the list is empty.');
        exit(FirstNode);
    end;

    procedure Insert(Value: Interface "Value FS")
    var
        NewNode: Codeunit "Value Linked List Node FS";
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

    procedure GetCount(): Integer
    begin
        exit(Count);
    end;
}
