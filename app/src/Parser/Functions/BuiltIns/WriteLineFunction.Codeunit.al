codeunit 69204 "Write Line Function FS" implements "Function FS"
{
    procedure GetReturnType(): Enum "Type FS"
    begin
        exit(Enum::"Type FS"::Void);
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    var
        VoidValue: Codeunit "Void Value FS";
        Node: Codeunit "Value Linked List Node FS";
        Text: Text;
    begin
        ValueLinkedList.First(Node); // TODO what if it does not exist?
        Text := Node.Value().GetValue();

        Runtime.WriteLine(Text);

        exit(VoidValue);
    end;
}