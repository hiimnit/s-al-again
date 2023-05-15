interface "Function FS"
{
    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"

    procedure GetReturnType(): Enum "Type FS"
}