interface "Node FS"
{
    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";

    procedure ValidateSemantics(SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
}