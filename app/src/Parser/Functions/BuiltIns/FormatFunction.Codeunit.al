codeunit 69205 "Format Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('Format');
    end;

    procedure GetReturnType(): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.TextSymbol());
    end;

    procedure GetArity(): Integer // TODO return a record with min and max?
    begin
        exit(1);
    end;

    // TODO this will make things difficult for functions with
    // >>>> variable parity - message, error, setrange...
    procedure GetParameters(var ParameterSymbol: Record "Symbol FS")
    begin
        ParameterSymbol.InsertAny('Any', 1);

        // TODO allow to create multiple sets here?
        // >>>> call match from here? arity as parameter?
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    var
        Node: Codeunit "Value Linked List Node FS";
        TextValue: Codeunit "Text Value FS";
        Text: Text;
    begin
        Node := ValueLinkedList.First();

        Text := Format(Node.Value().GetValue());
        TextValue.SetValue(Text);

        exit(TextValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS");
    begin
        // TODO do not call this for built ins?
    end;
}