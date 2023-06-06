codeunit 69023 "Procedure Call Node FS" implements "Node FS"
{
    var
        Arguments: Codeunit "Node Linked List FS";
        Function: Interface "Function FS";
        Name: Text[120];

    procedure Init
    (
        NewName: Text[120];
        NewArguments: Codeunit "Node Linked List FS"
    )
    begin
        Name := NewName;
        Arguments := NewArguments;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Procedure Call");
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
        ArgumentNode: Codeunit "Node Linked List Node FS";
        ArgumentValues: Codeunit "Value Linked List FS";
        Value: Interface "Value FS";
    begin
        if Arguments.First(ArgumentNode) then
            repeat
                Value := ArgumentNode.Value().Evaluate(Runtime);
                ArgumentValues.Insert(Value);
            until not ArgumentNode.Next(ArgumentNode);

        exit(Function.Evaluate(Runtime, ArgumentValues, TopLevel));
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    begin
        Function := Runtime.LookupFunction(Name);

        Function.ValidateCallArguments(
            Runtime,
            SymbolTable,
            Arguments
        );

        exit(Function.GetReturnType(TopLevel));
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