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

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Exit Statement");
    end;

    procedure Assignable(): Boolean
    begin
        exit(false);
    end;

    procedure IsLiteralValue(): Boolean
    begin
        exit(false);
    end;

    var
        TopLevel: Boolean;

    procedure SetTopLevel(NewTopLevel: Boolean)
    begin
        TopLevel := NewTopLevel;
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        Value: Interface "Value FS";
    begin
        if not ExpressionSet then
            exit(VoidValue);

        Value := Expression.Evaluate(Runtime);
        Runtime.GetMemory().SetReturnValue(Value);

        Runtime.SetExited(); // TODO move this to current memory?
        exit(Value);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS"
    var
        Symbol: Record "Symbol FS";
    begin
        if not ExpressionSet then
            exit(SymbolTable.VoidSymbol());

        if SymbolTable.GetReturnType().Type = Enum::"Type FS"::Void then
            Error('Unexpected return value expression, return value should be void.');

        Symbol := Expression.ValidateSemantics(Runtime, SymbolTable);
        if not Symbol.CompareExact(SymbolTable.GetReturnType()) then
            Error(
                'Return type missmatch, expected %1, got %2.',
                SymbolTable.GetReturnType().TypeToText(),
                Symbol.TypeToText()
            );

        exit(SymbolTable.VoidSymbol());
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
}