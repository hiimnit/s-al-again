codeunit 69021 "While Statement Node FS" implements "Node FS"
{
    var
        Statement: Interface "Node FS";
        Expression: Interface "Node FS";

    procedure Init
    (
        NewStatement: Interface "Node FS";
        NewExpression: Interface "Node FS"
    )
    begin
        Statement := NewStatement;
        Expression := NewExpression;
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        Value: Interface "Value FS";
    begin
        while true do begin
            Value := Expression.Evaluate(Runtime);
            if not Value.GetValue() then
                break;

            Statement.Evaluate(Runtime);
        end;

        exit(VoidValue);
    end;

    procedure ValidateSemantics(SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        Symbol: Record "Symbol FS";
    begin
        Symbol := Expression.ValidateSemantics(SymbolTable);
        if Symbol.Type <> Symbol.Type::Boolean then
            Error('While condition must evaluate to a boolean value.');

        Statement.ValidateSemantics(SymbolTable);

        exit(SymbolTable.VoidSymbol());
    end;
}