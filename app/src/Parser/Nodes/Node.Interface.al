interface "Node FS"
{
    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";

    procedure ValidateSemantics
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS"
    ): Record "Symbol FS";
    procedure ValidateSemanticsWithContext
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        ContextSymbol: Record "Symbol FS"
    ): Record "Symbol FS";

    // used to mark top level leaf expressions - this should mean the return value is not used
    // XXX instead make a wrapper for interface node and put this there?
    procedure SetTopLevel(TopLevel: Boolean)

    procedure GetType(): Enum "Node Type FS"
}