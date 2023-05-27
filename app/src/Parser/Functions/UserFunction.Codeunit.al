codeunit 69025 "User Function FS" implements "Function FS"
{
    var
        SymbolTable: Codeunit "Symbol Table FS";
        Statements: Interface "Node FS";
        Name: Text[120];

    procedure Init
    (
        NewName: Text[120];
        NewSymbolTable: Codeunit "Symbol Table FS";
        NewStatements: Interface "Node FS"
    )
    begin
        Name := NewName;
        SymbolTable := NewSymbolTable;
        Statements := NewStatements;
    end;

    procedure GetName(): Text[120];
    begin
        exit(Name);
    end;

    procedure GetReturnType(): Record "Symbol FS"
    begin
        exit(SymbolTable.GetReturnType());
    end;

    procedure ValidateCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        ContextSymbolTable: Codeunit "Symbol Table FS";
        Arguments: Codeunit "Node Linked List FS"
    )
    var
        ParameterSymbol: Record "Symbol FS";
    begin
        SymbolTable.GetParameters(ParameterSymbol);

        Runtime.ValidateMethodCallArguments(
            Runtime,
            ContextSymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    var
        Memory: Codeunit "Memory FS";
        VoidValue: Codeunit "Void Value FS";
        Value: Interface "Value FS";
    begin
        Memory.Init(SymbolTable, ValueLinkedList);

        Runtime.PushMemory(Memory);
        Value := Statements.Evaluate(Runtime);

        Memory.DebugMessage();

        case Value.GetType() of
            Enum::"Type FS"::"Return Value":
                Value := Value.Copy(); // TODO a bit of a hack
            Enum::"Type FS"::"Default Return Value":
                if SymbolTable.GetReturnType().Type <> Enum::"Type FS"::Void then
                    Value := Memory.DefaultValueFromType(SymbolTable.GetReturnType())
                else
                    Value := VoidValue;
            Enum::"Type FS"::Void:
                ;
            else
                Error('Unimplemented return type %1.', Value.GetType());
        end;

        Runtime.PopMemory();

        exit(Value);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS")
    begin
        SymbolTable.Validate();
        Statements.ValidateSemantics(Runtime, SymbolTable);
    end;
}