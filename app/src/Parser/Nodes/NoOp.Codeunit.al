codeunit 69015 "NoOp FS" implements "Node FS"
{
    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
    begin
        exit(VoidValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    begin
        exit(SymbolTable.VoidSymbol());
    end;
}