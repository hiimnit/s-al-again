interface "Function FS"
{
    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"

    procedure GetName(): Text[120]
    procedure GetReturnType(): Record "Symbol FS"
    procedure GetArity(): Integer
    procedure GetParameters(var ParameterSymbol: Record "Symbol FS")

    // TODO procedure SetTopLevel() - both functions and methods? useful in methods like get
}