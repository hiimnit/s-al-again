codeunit 69026 "Method Call Node FS" implements "Node FS"
{
    var
        Arguments: Codeunit "Node Linked List FS";
        Expression: Interface "Node FS";
        Method: Interface "Method FS"; // TODO keep/remove this?
        Name: Text[120];

    procedure Init
    (
        NewExpression: Interface "Node FS";
        NewName: Text[120];
        NewArguments: Codeunit "Node Linked List FS"
    )
    begin
        Expression := NewExpression;
        Name := NewName;
        Arguments := NewArguments;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Method Call");
    end;

    procedure Assignable(): Boolean
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
        Self: Interface "Value FS";
    begin
        Self := Expression.Evaluate(Runtime);

        exit(Method.Evaluate(Runtime, Self, Arguments, TopLevel));
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        Symbol: Record "Symbol FS";
    begin
        Symbol := Expression.ValidateSemantics(Runtime, SymbolTable);

        Method := Runtime.LookupMethod(
            Symbol.Type,
            Name
        );

        Method.ValidateCallArguments(
            Runtime,
            SymbolTable,
            Symbol,
            Arguments
        );

        exit(SymbolTable.SymbolFromType(Method.GetReturnType(TopLevel)));
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