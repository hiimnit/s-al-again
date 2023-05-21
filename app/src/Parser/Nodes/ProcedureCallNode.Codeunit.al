codeunit 69023 "Procedure Call Node FS" implements "Node FS"
{
    var
        Arguments: Codeunit "Node Linked List FS";
        Name: Text[120];

    procedure Init
    (
        NewName: Text[120];
        NewArguments: Codeunit "Node Linked List FS"
    )
    begin
        Name := NewName;
        Arguments := NewArguments;
    end;

    var
        TopLevel: Boolean;

    procedure SetTopLevel(NewTopLevel: Boolean)
    begin
        TopLevel := NewTopLevel;
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        ArgumentNode: Codeunit "Node Linked List Node FS";
        ArgumentValues: Codeunit "Value Linked List FS";
        Function: Interface "Function FS";
        Value: Interface "Value FS";
    begin
        Function := Runtime.LookupFunction(Name);

        if Arguments.First(ArgumentNode) then
            repeat
                Value := ArgumentNode.Value().Evaluate(Runtime);
                ArgumentValues.Insert(Value);
            until not ArgumentNode.Next(ArgumentNode);

        exit(Function.Evaluate(Runtime, ArgumentValues));
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        Function: Interface "Function FS";
    begin
        Function := Runtime.LookupFunction(Name);

        ValidateProcedureCallArguments(
            Runtime,
            SymbolTable,
            Function
        );

        exit(Function.GetReturnType());
    end;

    procedure ValidateSemanticsWithContext
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        ContextSymbol: Record "Symbol FS"
    ): Record "Symbol FS";
    begin
        exit(ValidateSemantics(
            Runtime,
            SymbolTable
        ));
    end;

    // TODO this will make things difficult for functions with
    // >>>> variable parity - message, error, setrange...
    local procedure ValidateProcedureCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Function: Interface "Function FS"
    )
    var
        ParameterSymbol, Symbol : Record "Symbol FS";
        ArgumentNode: Codeunit "Node Linked List Node FS";
    begin
        if Arguments.GetCount() <> Function.GetArity() then
            Error('Parameter count missmatch when calling function %1.', Function.GetName());

        Function.GetParameters(ParameterSymbol);
        ParameterSymbol.SetCurrentKey(Order); // TODO this feels wrong
        if not ParameterSymbol.FindSet() then
            exit;

        ArgumentNode := Arguments.First();

        while true do begin
            Symbol := ArgumentNode.Value().ValidateSemantics(Runtime, SymbolTable);
            if not TypesMatch(ParameterSymbol, Symbol) then
                Error(
                    'Parameter call missmatch when calling function %1.\\Expected %2, got %3.',
                    Function.GetName(),
                    ParameterSymbol.TypeToText(),
                    Symbol.TypeToText()
                );

            if ParameterSymbol.Next() = 0 then
                break;
            ArgumentNode := ArgumentNode.Next();
        end;
    end;

    local procedure TypesMatch
    (
        ExpectedSymbol: Record "Symbol FS";
        ActualSymbol: Record "Symbol FS"
    ): Boolean
    begin
        if ExpectedSymbol.Type = ExpectedSymbol.Type::Any then
            exit(ActualSymbol.Type <> ActualSymbol.Type::Void);
        exit(ExpectedSymbol.Compare(ActualSymbol));
    end;
}