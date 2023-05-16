codeunit 69920 "Node Linked List Node FS"
{
    var
        NextNode: Codeunit "Node Linked List Node FS";
        HasNextNode: Boolean;
        InnerValue: Interface "Node FS";

    procedure Value(NewValue: Interface "Node FS")
    begin
        InnerValue := NewValue;
    end;

    procedure Value(): Interface "Node FS"
    begin
        exit(InnerValue);
    end;

    procedure SetNext(NewNext: Codeunit "Node Linked List Node FS")
    begin
        NextNode := NewNext;
        HasNextNode := true;
    end;

    procedure HasNext(): Boolean
    begin
        exit(HasNextNode);
    end;

    procedure Next(var Node: Codeunit "Node Linked List Node FS"): Boolean
    begin
        if not HasNextNode then
            exit(false);
        Node := NextNode;
        exit(true);
    end;

    procedure Next(): Codeunit "Node Linked List Node FS"
    begin
        if not HasNextNode then
            Error('Out of bounds, there is no next node.');
        exit(NextNode);
    end;
}