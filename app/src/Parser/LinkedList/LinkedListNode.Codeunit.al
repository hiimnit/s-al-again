codeunit 69920 "Linked List Node FS"
{
    var
        NextNode: Codeunit "Linked List Node FS";
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

    procedure SetNext(NewNext: Codeunit "Linked List Node FS")
    begin
        NextNode := NewNext;
        HasNextNode := true;
    end;

    procedure HasNext(): Boolean
    begin
        exit(HasNextNode);
    end;

    procedure Next(var Node: Codeunit "Linked List Node FS"): Boolean
    begin
        if not HasNextNode then
            exit(false);
        Node := NextNode;
        exit(true);
    end;
}