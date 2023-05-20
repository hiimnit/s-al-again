codeunit 69002 "Parse Call Result FS"
{
    var
        Node: Interface "Node FS";

    procedure Init
    (
        NewNode: Interface "Node FS"
    )
    begin
        Node := NewNode;
    end;

    var
        VariableNode: Codeunit "Variable Node FS";
        VariableSet: Boolean;

    procedure InitVariable
    (
        NewVariableNode: Codeunit "Variable Node FS"
    )
    begin
        VariableNode := NewVariableNode;
        VariableSet := true;

        Init(VariableNode);
    end;

    procedure GetNode(): Interface "Node FS"
    begin
        exit(Node);
    end;

    procedure IsVariable(): Boolean
    begin
        exit(VariableSet);
    end;

    procedure GetVariableName(): Text[120]
    begin
        exit(VariableNode.GetName());
    end;
}