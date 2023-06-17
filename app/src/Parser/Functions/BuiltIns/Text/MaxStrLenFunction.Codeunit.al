codeunit 69223 "MaxStrLen Function FS" implements "Function FS"
{
    var
        Length: Integer;
        LengthDefined: Boolean;

    procedure GetName(): Text[120];
    begin
        exit('MaxStrLen');
    end;

    procedure GetReturnType(TopLevel: Boolean): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.IntegerSymbol());
    end;

    procedure ValidateCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Arguments: Codeunit "Node Linked List FS"
    )
    var
        ParameterSymbol, Symbol : Record "Symbol FS";
        Node: Interface "Node FS";
    begin
        if Arguments.GetCount() <> 1 then
            Error('Parameter count missmatch when calling method %1.', GetName());

        Node := Arguments.First().Value();
        Symbol := Node.ValidateSemantics(Runtime, SymbolTable);

        ParameterSymbol.InsertText('Text', 1);
        if not Runtime.MatchTypesAnyOrCoercible(
            ParameterSymbol,
            Symbol
        ) then
            Error(
                'Parameter call missmatch when calling method %1.\\Expected %2, got %3.',
                GetName(),
                ParameterSymbol.TypeToText(),
                Symbol.TypeToText()
            );

        Length := Symbol.Length;
        LengthDefined := Symbol."Length Defined";
    end;

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS"
    var
        IntegerValue: Codeunit "Integer Value FS";
        Value: Integer;
    begin
        Value := Length;
        if not LengthDefined then
            Value := 2147483647;

        IntegerValue.SetValue(Value);
        exit(IntegerValue);
    end;
}