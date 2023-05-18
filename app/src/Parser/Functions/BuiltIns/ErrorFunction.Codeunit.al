codeunit 69203 "Error Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('Error');
    end;

    procedure GetReturnType(): Enum "Type FS"
    begin
        exit(Enum::"Type FS"::Void);
    end;

    procedure GetArity(): Integer
    begin
        exit(1);
    end;

    // TODO this will make things difficult for functions with
    // >>>> variable parity - message, error, setrange...
    procedure GetParameters(var ParameterSymbol: Record "Symbol FS")
    begin
        ParameterSymbol.InsertText('Text', 1);
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    var
        VoidValue: Codeunit "Void Value FS";
        Node: Codeunit "Value Linked List Node FS";
        Text: Text;
    begin
        Node := ValueLinkedList.First();
        Text := Node.Value().GetValue();

        Error(Text);

        exit(VoidValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS");
    begin
        // TODO do not call this for built ins?
    end;
}