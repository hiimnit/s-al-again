codeunit 69025 "User Function FS" implements "Function FS"
{
    var
        FunctionParameter: Record "Function Parameter FS";
        Statements: Interface "Node FS";
        ReturnType: Enum "Type FS";

    procedure Init
    (
        NewStatements: Interface "Node FS";
        NewReturnType: Enum "Type FS"
    )
    begin
        Statements := NewStatements;
        ReturnType := NewReturnType;
    end;

    procedure DefineParameter
    (
        Type: Enum "Type FS"
    )
    begin
        FunctionParameter.Init();
        FunctionParameter.Order += 1;
        FunctionParameter.Type := Type;
        FunctionParameter.Insert();
    end;

    procedure GetReturnType(): Enum "Type FS"
    begin
        exit(ReturnType);
    end;


    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    begin
        // TODO
    end;
}