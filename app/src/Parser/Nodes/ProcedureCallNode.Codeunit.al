codeunit 69023 "Procedure Call Node FS" implements "Node FS"
{
    var
        Arguments: Codeunit "Node Linked List FS";
        Function: Interface "Function FS";
        Name: Text[120];

    procedure Init
    (
        NewName: Text[120]
    )
    begin
        Name := NewName;
    end;

    procedure AddArgument(Argument: Interface "Node FS")
    begin
        Arguments.Insert(Argument);
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        ArgumentNode: Codeunit "Node Linked List Node FS";
        ArgumentValues: Codeunit "Value Linked List FS";
        Value: Interface "Value FS";
    begin
        if Arguments.First(ArgumentNode) then
            repeat
                Value := ArgumentNode.Value().Evaluate(Runtime);
                ArgumentValues.Insert(Value);
            until not ArgumentNode.Next(ArgumentNode);

        // TODO make sure Function is set
        exit(Function.Evaluate(Runtime, ArgumentValues));
    end;

    procedure ValidateSemantics(SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    begin
        Function := SymbolTable.LookupFunction(Name);

        // FIXME 
        // >>>>> lookup function, validate its parameters and return its return type
        // >>>>> also update variable node to check that symbol is not a function?

        exit(SymbolTable.SymbolFromType(Function.GetReturnType()));
    end;
}