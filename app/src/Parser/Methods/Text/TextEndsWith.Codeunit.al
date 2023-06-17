codeunit 69337 "Text EndsWith FS" implements "Method FS"
{
    SingleInstance = true;

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        Arguments: Codeunit "Node Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS"
    var
        BooleanValue: Codeunit "Boolean Value FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        Node: Codeunit "Value Linked List Node FS";
        Text, Subtext : Text;
    begin
        Text := Self.GetValue();

        ValueLinkedList := Runtime.EvaluateArguments(Runtime, Arguments);
        Node := ValueLinkedList.First();
        Subtext := Node.Value().GetValue();

        BooleanValue.SetValue(Text.EndsWith(Subtext));
        exit(BooleanValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('EndsWith');
    end;

    procedure GetReturnType(TopLevel: Boolean): Enum "Type FS";
    begin
        exit(Enum::"Type FS"::Boolean);
    end;

    procedure ValidateCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Self: Record "Symbol FS";
        Arguments: Codeunit "Node Linked List FS"
    )
    var
        ParameterSymbol: Record "Symbol FS";
    begin
        ParameterSymbol.InsertText('Value', 1);

        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;
}