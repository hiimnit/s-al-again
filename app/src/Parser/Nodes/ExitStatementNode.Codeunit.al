codeunit 69024 "Exit Statement Node FS" implements "Node FS"
{
    var
        Expression: Interface "Node FS";
        ExpressionSet: Boolean;

    procedure Init
    (
        NewExpression: Interface "Node FS"
    )
    begin
        Expression := NewExpression;
        ExpressionSet := true;
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        ReturnValue: Codeunit "Return Value FS";
    begin
        if not ExpressionSet then
            exit(ReturnValue);

        ReturnValue.Init(
            Expression.Evaluate(Runtime)
        );
        exit(ReturnValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS"
    var
        Symbol: Record "Symbol FS";
    begin
        if not ExpressionSet then
            exit(SymbolTable.VoidSymbol());

        Symbol := Expression.ValidateSemantics(Runtime, SymbolTable);
        if Symbol.Type <> Symbol.Type::Void then
            if Symbol.Type <> SymbolTable.GetReturnType() then
                Error('Return type missmatch, expected %1, got %2.', SymbolTable.GetReturnType(), Symbol.Type);

        exit(SymbolTable.VoidSymbol());
    end;
}