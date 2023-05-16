interface "Function FS"
{
    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS")

    procedure GetName(): Text[120]
    procedure GetReturnType(): Enum "Type FS"
    procedure GetArity(): Integer
    procedure GetParameters(var ParameterSymbol: Record "Symbol FS")
}