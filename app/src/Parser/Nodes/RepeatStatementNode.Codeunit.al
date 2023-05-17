codeunit 69022 "Repeat Statement Node FS" implements "Node FS"
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
            Value := Statement.Evaluate(Runtime);
            if Value.GetType() in [
                Enum::"Type FS"::"Return Value",
                Enum::"Type FS"::"Default Return Value"
            ] then
                exit(Value);

            Value := Expression.Evaluate(Runtime);
            if Value.GetValue() then
                break;
        end;

        exit(VoidValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        Symbol: Record "Symbol FS";
    begin
        Statement.ValidateSemantics(Runtime, SymbolTable);

        Symbol := Expression.ValidateSemantics(Runtime, SymbolTable);
        if Symbol.Type <> Symbol.Type::Boolean then
            Error('Repeat condition must evaluate to a boolean value.');

        exit(SymbolTable.VoidSymbol());
    end;
}