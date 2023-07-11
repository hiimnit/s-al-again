codeunit 69025 "User Function FS" implements "Function FS"
{
    var
        SymbolTable: Codeunit "Symbol Table FS";
        Statements: Interface "Node FS";
        Name: Text[120];

    procedure Init
    (
        NewName: Text[120];
        NewSymbolTable: Codeunit "Symbol Table FS"
    )
    begin
        Name := NewName;
        SymbolTable := NewSymbolTable;
    end;

    procedure SetStatements
    (
        NewStatements: Interface "Node FS"
    )
    begin
        Statements := NewStatements;
    end;

    var
        StartLine, StartColumn : Integer;
        EndLine, EndColumn : Integer; // TODO not needed?

    procedure SetPositionStart
    (
        NewStartLine: Integer;
        NewStartColumn: Integer
    )
    begin
        StartLine := NewStartLine;
        StartColumn := NewStartColumn;
    end;

    procedure GetStartLine(): Integer
    begin
        exit(StartLine);
    end;

    procedure GetStartColumn(): Integer
    begin
        exit(StartColumn);
    end;

    procedure SetPositionEnd
    (
        NewEndLine: Integer;
        NewEndColumn: Integer
    )
    begin
        EndLine := NewEndLine;
        EndColumn := NewEndColumn;
    end;

    procedure StartsBefore
    (
        Line: Integer;
        Column: Integer
    ): Boolean
    begin
        if StartLine < Line then
            exit(true);
        if StartLine > Line then
            exit(false);
        exit(StartColumn <= Column);
    end;

    procedure EndsAfter // TODO unused
    (
        Line: Integer;
        Column: Integer
    ): Boolean
    begin
        if EndLine > Line then
            exit(true);
        if EndLine < Line then
            exit(false);
        exit(EndColumn > Column);
    end;

    procedure GetName(): Text[120];
    begin
        exit(Name);
    end;

    procedure GetReturnType(TopLevel: Boolean): Record "Symbol FS"
    begin
        exit(SymbolTable.GetReturnType());
    end;

    procedure GetSymbolTable(): Codeunit "Symbol Table FS"
    begin
        exit(SymbolTable);
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

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS"
    var
        Memory: Codeunit "Memory FS";
        Value: Interface "Value FS";
    begin
        Memory.Init(SymbolTable, ValueLinkedList);

        Runtime.PushMemory(Memory);

        Statements.Evaluate(Runtime);
        Value := Runtime.GetMemory().GetReturnValue();

        Runtime.PopMemory();
        Runtime.ResetExited();

        exit(Value);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS")
    begin
        SymbolTable.Validate();
        Statements.ValidateSemantics(Runtime, SymbolTable);
    end;

    procedure GetSignature(): Text
    var
        ParameterSymbol, ReturnTypeSymbol : Record "Symbol FS";
        SignatureBuilder: TextBuilder;
    begin
        SignatureBuilder.Append(GetName());

        SignatureBuilder.Append('(');
        SymbolTable.GetParameters(ParameterSymbol);
        ParameterSymbol.SetCurrentKey(Order);
        if ParameterSymbol.FindSet() then
            repeat
                if SignatureBuilder.Length <> 0 then
                    SignatureBuilder.Append('; ');
                SignatureBuilder.Append(ParameterSymbol.ToText());
            until ParameterSymbol.Next() = 0;
        SignatureBuilder.Append(')');

        ReturnTypeSymbol := GetReturnType(false);
        if ReturnTypeSymbol.Type <> ReturnTypeSymbol.Type::Void then
            SignatureBuilder.Append(ReturnTypeSymbol.ToText());

        exit(SignatureBuilder.ToText());
    end;
}