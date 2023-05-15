interface "Node FS"
{
    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";

    procedure ValidateSemantics(SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
}