codeunit 69204 "Write Line Function FS" implements "Function FS"
{
    procedure GetName(): Text[120];
    begin
        exit('WriteLine');
    end;

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

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS");
    begin
        // TODO do not call this for built ins?
    end;
}