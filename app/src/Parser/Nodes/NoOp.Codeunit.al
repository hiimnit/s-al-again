codeunit 69015 "NoOp FS" implements "Node FS"
{
    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
    begin
        exit(VoidValue);
    end;

    procedure ValidateSemantics(SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    begin
        exit(SymbolTable.VoidSymbol());
    end;
}