codeunit 69025 "User Function FS" implements "Function FS"
{
    var
        SymbolTable: Codeunit "Symbol Table FS";
        Statements: Interface "Node FS";
        ReturnType: Enum "Type FS";
        Name: Text[120];

    procedure Init
    (
        NewName: Text[120];
        NewSymbolTable: Codeunit "Symbol Table FS";
        NewStatements: Interface "Node FS";
        NewReturnType: Enum "Type FS"
    )
    begin
        Name := NewName;
        SymbolTable := NewSymbolTable;
        Statements := NewStatements;
        ReturnType := NewReturnType;
    end;

    procedure GetName(): Text[120];
    begin
        exit(Name);
    end;

    procedure GetReturnType(): Enum "Type FS"
    begin
        exit(ReturnType);
    end;

    procedure GetArity(): Integer
    begin
        exit(SymbolTable.GetParameterCount());
    end;

    procedure GetParameters(var ParameterSymbol: Record "Symbol FS")
    begin
        SymbolTable.GetParameters(ParameterSymbol);
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    var
        Memory: Codeunit "Memory FS";
        Value: Interface "Value FS";
    begin
        Memory.Init(SymbolTable, ValueLinkedList);

        Runtime.PushMemory(Memory);

        Value := Statements.Evaluate(Runtime);

        Memory.DebugMessage();

        exit(Value);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS")
    begin
        Statements.ValidateSemantics(Runtime, SymbolTable);
    end;
}