codeunit 69922 "Value Linked List Node FS"
{
    var
        NextNode: Codeunit "Value Linked List Node FS";
        HasNextNode: Boolean;
        InnerValue: Interface "Value FS";

    procedure Value(NewValue: Interface "Value FS")
    begin
        InnerValue := NewValue;
    end;

    procedure Value(): Interface "Value FS"
    begin
        exit(InnerValue);
    end;

    procedure SetNext(NewNext: Codeunit "Value Linked List Node FS")
    begin
        NextNode := NewNext;
        HasNextNode := true;
    end;

    procedure HasNext(): Boolean
    begin
        exit(HasNextNode);
    end;

    procedure Next(var Node: Codeunit "Value Linked List Node FS"): Boolean
    begin
        if not HasNextNode then
            exit(false);
        Node := NextNode;
        exit(true);
    end;
}