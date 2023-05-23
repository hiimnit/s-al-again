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
        ParameterSymbol.InsertNumber('Length', 2);
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
        if not (Symbol.Type in [Symbol.Type::Text, Symbol.Type::Number]) then
            Error(
                'Parameter call missmatch when calling method %1.\\Expected %2 or %3, got %4.',
                GetName(),
                Symbol.Type::Text,
                Symbol.Type::Number,
                Symbol.TypeToText()
            );
    end;

    // TODO format has two issues
    // >>>> 1. unexpected results when formatting "integers"
    // >>>> 2. there might be a problem passing everything in as a variant? (Standard format number 4 does not exist for the type 'Variant')
    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
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
            Text := Format(Input.GetValue());
            TextValue.SetValue(Text);
            exit(TextValue);
        end;

        Node := Node.Next();
        Length := Node.Value();
        if not Node.HasNext() then begin
            Text := Format(Input.GetValue(), Length.GetValue());
            TextValue.SetValue(Text);
            exit(TextValue);
        end;

        Node := Node.Next();
        FormatVariant := Node.Value().GetValue();
        case true of
            FormatVariant.IsText():
                begin
                    FormatString := FormatVariant;
                    Text := Format(Input.GetValue(), Length.GetValue(), FormatString);
                end;
            FormatVariant.IsInteger(),
            FormatVariant.IsDecimal():
                begin
                    FormatNumber := FormatVariant;
                    Text := Format(Input.GetValue(), Length.GetValue(), FormatNumber);
                end;
            else
                Error('Unimplementd: Unexpcted format.');
        end;

        TextValue.SetValue(Text);
        exit(TextValue);
    end;
}