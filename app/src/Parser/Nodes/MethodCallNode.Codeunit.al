codeunit 69026 "Method Call Node FS" implements "Node FS"
{
    var
        Arguments: Codeunit "Node Linked List FS";
        Expression: Interface "Node FS";
        Method: Interface "Method FS";
        Name: Text[120];

    procedure Init
    (
        NewExpression: Interface "Node FS";
        NewName: Text[120]
    )
    begin
        Expression := NewExpression;
        Name := NewName;
    end;

    procedure AddArgument(Argument: Interface "Node FS")
    begin
        Arguments.Insert(Argument);
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        ArgumentNode: Codeunit "Node Linked List Node FS";
        ArgumentValues: Codeunit "Value Linked List FS";

        Value: Interface "Value FS";
    begin
        Value := Expression.Evaluate(Runtime);

        if Arguments.First(ArgumentNode) then
            repeat
                Value := ArgumentNode.Value().Evaluate(Runtime);
                ArgumentValues.Insert(Value);
            until not ArgumentNode.Next(ArgumentNode);

        exit(Method.Evaluate(Runtime, Value, ArgumentValues));
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        Symbol: Record "Symbol FS";
    begin
        Symbol := Expression.ValidateSemantics(Runtime, SymbolTable);

        Method := Runtime.LookupMethod(
            Symbol.Type,
            Name
        );

        ValidateProcedureCallArguments(
            Runtime,
            SymbolTable
        );

        exit(SymbolTable.SymbolFromType(Method.GetReturnType()));
    end;

    // TODO this will make things difficult for functions with
    // >>>> variable parity - message, error, setrange...
    local procedure ValidateProcedureCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS"
    )
    var
        ParameterSymbol, Symbol : Record "Symbol FS";
        ArgumentNode: Codeunit "Node Linked List Node FS";
    begin
        if Arguments.GetCount() <> Method.GetArity() then
            Error('Parameter count missmatch when calling method %1.', Method.GetName());

        Method.GetParameters(ParameterSymbol);
        ParameterSymbol.SetCurrentKey(Order); // TODO this feels wrong
        if not ParameterSymbol.FindSet() then
            exit;

        ArgumentNode := Arguments.First();

        while true do begin
            Symbol := ArgumentNode.Value().ValidateSemantics(Runtime, SymbolTable);
            if not TypesMatch(ParameterSymbol.Type, Symbol.Type) then
                Error(
                    'Parameter call missmatch when calling method %1.\\Expected %2, got %3.',
                    Method.GetName(),
                    ParameterSymbol.Type,
                    Symbol.Type
                );

            if ParameterSymbol.Next() = 0 then
                break;
            ArgumentNode := ArgumentNode.Next();
        end;
    end;

    local procedure TypesMatch
    (
        ExpectedType: Enum "Type FS";
        ActualType: Enum "Type FS"
    ): Boolean
    begin
        if ExpectedType = ExpectedType::Any then
            exit(ActualType <> ActualType::Void);
        exit(ExpectedType = ActualType);
    end;
}