codeunit 69023 "Procedure Call Node FS" implements "Node FS"
{
    var
        Arguments: Codeunit "Node Linked List FS";
        Name: Text[120];

    procedure Init
    (
        NewName: Text[120]
    )
    begin
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

        exit(SymbolTable.SymbolFromType(Function.GetReturnType()));
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
            if not TypesMatch(ParameterSymbol.Type, Symbol.Type) then
                Error(
                    'Parameter call missmatch when calling function %1.\\Expected %2, got %3.',
                    Function.GetName(),
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