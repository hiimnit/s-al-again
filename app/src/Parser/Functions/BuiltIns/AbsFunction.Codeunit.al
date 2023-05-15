codeunit 69200 "Abs Function FS" implements "Function FS"
{
    procedure GetReturnType(): Enum "Type FS"
    begin
        exit(Enum::"Type FS"::Number);
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    var
        NumericValue: Codeunit "Numeric Value FS";
        Node: Codeunit "Value Linked List Node FS";
        Value: Decimal;
    begin
        ValueLinkedList.First(Node); // TODO what if it does not exist?

        Value := Abs(Node.Value().GetValue());
        NumericValue.SetValue(Value);

        exit(NumericValue);
    end;
}