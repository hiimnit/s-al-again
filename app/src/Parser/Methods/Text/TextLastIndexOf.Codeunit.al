codeunit 69340 "Text LastIndexOf FS" implements "Method FS"
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
        IntegerValue: Codeunit "Integer Value FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        Node: Codeunit "Value Linked List Node FS";
        Subtext, StartIndex : Interface "Value FS";
        Text: Text;
    begin
        Text := Self.GetValue();

        ValueLinkedList := Runtime.EvaluateArguments(Runtime, Arguments);
        Node := ValueLinkedList.First();
        Subtext := Node.Value();

        if not Node.HasNext() then begin
            IntegerValue.SetValue(Text.LastIndexOf(
                Subtext.GetValue()
            ));
            exit(IntegerValue);
        end;

        Node := Node.Next();
        StartIndex := Node.Value();

        IntegerValue.SetValue(Text.LastIndexOf(
            Subtext.GetValue(),
            StartIndex.GetValue()
        ));
        exit(IntegerValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('LastIndexOf');
    end;

    procedure GetReturnType(TopLevel: Boolean): Enum "Type FS";
    begin
        exit(Enum::"Type FS"::Integer);
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
        if Arguments.GetCount() > 1 then
            ParameterSymbol.InsertInteger('StartIndex', 2);

        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;
}