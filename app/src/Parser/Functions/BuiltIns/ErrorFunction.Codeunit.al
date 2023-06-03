codeunit 69203 "Error Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('Error');
    end;

    procedure GetReturnType(TopLevel: Boolean): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.VoidSymbol());
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
        if not (Arguments.GetCount() in [1 .. Runtime.MaxAllowedSubstitutions() + 1]) then
            Error('Parameter count missmatch when calling method %1.', GetName());

        // first argument must be the text template
        ArgumentNode := Arguments.First();
        Symbol := ArgumentNode.Value().ValidateSemantics(Runtime, SymbolTable);
        ParameterSymbol.InsertText('Template', 1);
        if not Runtime.MatchTypesCoercible(ParameterSymbol, Symbol) then
            Error(
                'Parameter call missmatch when calling method %1.\\Expected %2, got %3.',
                GetName(),
                ParameterSymbol.TypeToText(),
                Symbol.TypeToText()
            );

        // all other arguments can be anything
        ParameterSymbol.InsertAny('Any', 2);
        while ArgumentNode.Next(ArgumentNode) do begin
            Symbol := ArgumentNode.Value().ValidateSemantics(Runtime, SymbolTable);
            if not Runtime.MatchTypesAnyOrCoercible(ParameterSymbol, Symbol) then
                Error(
                    'Parameter call missmatch when calling method %1.\\Expected %2, got %3.',
                    GetName(),
                    ParameterSymbol.TypeToText(),
                    Symbol.TypeToText()
                );
        end;
    end;

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS"
    var
        VoidValue: Codeunit "Void Value FS";
        Node: Codeunit "Value Linked List Node FS";
        Text: Text;
    begin
        Node := ValueLinkedList.First();
        Text := Node.Value().GetValue();

        Error(Runtime.SubstituteText(Text, Node, ValueLinkedList.GetCount() - 1));

        exit(VoidValue);
    end;
}