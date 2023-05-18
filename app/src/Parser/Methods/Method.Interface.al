interface "Method FS"
{
    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        ValueLinkedList: Codeunit "Value Linked List FS"
    ): Interface "Value FS"

    procedure GetName(): Text[120]
    procedure GetInputType(): Enum "Type FS"
    procedure GetReturnType(): Enum "Type FS"
    procedure GetArity(): Integer
    procedure GetParameters(var ParameterSymbol: Record "Symbol FS")
}