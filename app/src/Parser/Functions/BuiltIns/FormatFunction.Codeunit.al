codeunit 69205 "Format Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('Format');
    end;

    procedure GetReturnType(TopLevel: Boolean): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.TextSymbol());
    end;

    procedure ValidateCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Arguments: Codeunit "Node Linked List FS"
    )
    var
        ParameterSymbol, Symbol : Record "Symbol FS";
        ArgumentNode: Codeunit "Node Linked List Node FS";
    begin
        if not (Arguments.GetCount() in [1 .. 3]) then
            Error('Parameter count missmatch when calling method %1.', GetName());

        ArgumentNode := Arguments.First();
        ParameterSymbol.InsertAny('Any', 1);
        Runtime.TestParameterVsArgument(
            Runtime,
            SymbolTable,
            GetName(),
            ParameterSymbol,
            ArgumentNode
        );

        if not ArgumentNode.HasNext() then
            exit;

        ArgumentNode := ArgumentNode.Next();
        ParameterSymbol.InsertInteger('Length', 2);
        Runtime.TestParameterVsArgument(
            Runtime,
            SymbolTable,
            GetName(),
            ParameterSymbol,
            ArgumentNode
        );

        if not ArgumentNode.HasNext() then
            exit;

        ArgumentNode := ArgumentNode.Next();
        Symbol := ArgumentNode.Value().ValidateSemantics(Runtime, SymbolTable);
        if not Runtime.MatchTypesAnyOrCoercible(SymbolTable.TextSymbol(), Symbol)
            and not Runtime.MatchTypesAnyOrCoercible(SymbolTable.IntegerSymbol(), Symbol)
        then
            Error(
                'Parameter call missmatch when calling method %1.\\Expected %2, got %3.',
                GetName(),
                Symbol.Type::Integer,
                Symbol.TypeToText()
            );
    end;

    // TODO formatting numbers has issues - unexpected results when formatting "integers"
    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS"
    var
        Node: Codeunit "Value Linked List Node FS";
        TextValue: Codeunit "Text Value FS";
        Input, Length : Interface "Value FS";
        FormatVariant: Variant;
        Text, FormatString : Text;
        FormatNumber: Integer;
    begin
        Node := ValueLinkedList.First();

        Input := Node.Value();
        if not Node.HasNext() then begin
            Text := Input.Format();
            TextValue.SetValue(Text);
            exit(TextValue);
        end;

        Node := Node.Next();
        Length := Node.Value();
        if not Node.HasNext() then begin
            Text := Input.Format(Length.GetValue());
            TextValue.SetValue(Text);
            exit(TextValue);
        end;

        Node := Node.Next();
        FormatVariant := Node.Value().GetValue();
        case true of
            FormatVariant.IsText():
                begin
                    FormatString := FormatVariant;
                    Text := Input.Format(Length.GetValue(), FormatString);
                end;
            FormatVariant.IsInteger(),
            FormatVariant.IsDecimal():
                begin
                    FormatNumber := FormatVariant;
                    Text := Input.Format(Length.GetValue(), FormatNumber);
                end;
            else
                Error('Unimplemented: Unexpected format.');
        end;

        TextValue.SetValue(Text);
        exit(TextValue);
    end;
}