interface "Function FS"
{
    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"

    procedure ValidateCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Arguments: Codeunit "Node Linked List FS"
    );

    procedure GetName(): Text[120]
    procedure GetReturnType(): Record "Symbol FS"

    // TODO procedure SetTopLevel() - both functions and methods? useful in methods like get
}