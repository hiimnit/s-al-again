codeunit 69001 "Parser FS"
{
    var
        CachedLexeme: Record "Lexeme FS";
        Lexer: Codeunit "Lexer FS";

    procedure Init(Input: Text)
    begin
        Lexer.Init(Input);
    end;

    procedure Parse(): Interface "Node FS"
    var
        Lexeme: Record "Lexeme FS";
        Memory: Codeunit "Memory FS";
        Node: Interface "Node FS";
    begin
        Node := ParseProgram(Memory);

        AssertNextLexeme(
            Lexeme.EOS()
        );

        Node.Visit(Memory);
    end;

    local procedure ParseProgram
    (
        // TODO temporary solution => return a list of variables
        // >>>> so that the interpreter can initialize them when needed
        Memory: Codeunit "Memory FS"
    ): Interface "Node FS"
    var
        Lexeme, PeekedLexeme : Record "Lexeme FS";
        CompoundStatement: Interface "Node FS";
    begin
        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"var")
        );

        while true do begin
            PeekedLexeme := PeekNextLexeme();
            if not PeekedLexeme.IsIdentifier() then
                break;

            Lexeme := NextLexeme();

            Memory.DefineLocalVariable(
                Lexeme."Identifier Name"
            );

            // TODO parse variable type

            AssertNextLexeme(
                Lexeme.Operator(Enum::"Operator FS"::";")
            );
        end;

        CompoundStatement := ParseCompoundStatement();
        AssertNextLexeme(
            Lexeme.Operator(Enum::"Operator FS"::";")
        );

        exit(CompoundStatement);
    end;

    local procedure ParseCompoundStatement(): Interface "Node FS"
    var
        Lexeme: Record "Lexeme FS";
        StatementList: Interface "Node FS";
    begin
        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"begin")
        );

        StatementList := ParseStatementList();

        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"end")
        );

        exit(StatementList);
    end;

    local procedure ParseStatementList(): Interface "Node FS"
    var
        PeekedLexeme: Record "Lexeme FS";
        StatementList: Codeunit "Statement List FS";
    begin
        while true do begin
            StatementList.Add(ParseStatement());

            PeekedLexeme := PeekNextLexeme();
            if not PeekedLexeme.IsOperator(Enum::"Operator FS"::";") then
                break;
            AssertNextLexeme(PeekedLexeme);
        end;

        exit(StatementList);
    end;

    local procedure ParseStatement(): Interface "Node FS"
    var
        Lexeme: Record "Lexeme FS";
        NoOp: Codeunit "NoOp FS";
    begin
        Lexeme := PeekNextLexeme();

        case true of
            Lexeme.IsKeyword(Enum::"Keyword FS"::"begin"):
                exit(ParseCompoundStatement());
            Lexeme.IsIdentifier():
                exit(ParseAssignmentStatement());

        end;

        exit(NoOp);
    end;

    local procedure ParseAssignmentStatement(): Interface "Node FS"
    var
        Lexeme, DummyLexeme : Record "Lexeme FS";
        AssignmentStatementNode: Codeunit "Assignment Statement Node FS";
    begin
        Lexeme := AssertNextLexeme(
            Lexeme.Identifier('TODO') // TODO
        );
        AssertNextLexeme(
            DummyLexeme.Operator(Enum::"Operator FS"::":=") // FIXME now this changing `Rec` makes things difficult
        );

        AssignmentStatementNode.Init(
            Lexeme."Identifier Name",
            ParseExpression()
        );

        exit(AssignmentStatementNode);
    end;

    local procedure ParseExpression(): Interface "Node FS"
    var
        PeekedLexeme, Lexeme : Record "Lexeme FS";
        ExpressionNode: Codeunit "Expression Node FS";
        Expression: Interface "Node FS";
    begin
        Expression := ParseTerm();

        while true do begin
            PeekedLexeme := PeekNextLexeme();

            if (PeekedLexeme.Type <> PeekedLexeme.Type::Operator)
                or not (PeekedLexeme."Operator Value" in [PeekedLexeme."Operator Value"::"+", PeekedLexeme."Operator Value"::"-"])
            then
                break;

            Lexeme := NextLexeme();

            Clear(ExpressionNode); // create new instance
            ExpressionNode.Init(
                Expression,
                ParseTerm(),
                Lexeme."Operator Value"
            );
            Expression := ExpressionNode;
        end;

        exit(Expression);
    end;

    local procedure ParseTerm(): Interface "Node FS"
    var
        PeekedLexeme, Lexeme : Record "Lexeme FS";
        TermNode: Codeunit "Term Node FS";
        Term: Interface "Node FS";
    begin
        Term := ParseFactor();

        while true do begin
            PeekedLexeme := PeekNextLexeme();

            if (PeekedLexeme.Type <> PeekedLexeme.Type::Operator)
                or not (PeekedLexeme."Operator Value" in [PeekedLexeme."Operator Value"::"*", PeekedLexeme."Operator Value"::"/"])
            then
                break;

            Lexeme := NextLexeme();

            Clear(TermNode); // create new instance
            TermNode.Init(
                Term,
                ParseFactor(),
                Lexeme."Operator Value"
            );
            Term := TermNode;
        end;

        exit(Term);
    end;

    local procedure ParseFactor(): Interface "Node FS"
    var
        PeekedLexeme, Lexeme : Record "Lexeme FS";
        NumberNode: Codeunit "Number Node FS";
        VariableNode: Codeunit "Variable Node FS";
        UnaryOperatorNode: Codeunit "Unary Operator Node FS";
        ExpressionNode: Interface "Node FS";
    begin
        PeekedLexeme := PeekNextLexeme();

        if PeekedLexeme.IsOperator() then
            case PeekedLexeme."Operator Value" of
                PeekedLexeme."Operator Value"::"(":
                    begin
                        NextLexeme();

                        ExpressionNode := ParseExpression();

                        AssertNextLexeme(
                            PeekedLexeme.Operator(Enum::"Operator FS"::")")
                        );

                        exit(ExpressionNode);
                    end;
                PeekedLexeme."Operator Value"::"+",
                PeekedLexeme."Operator Value"::"-":
                    begin
                        Lexeme := NextLexeme();

                        UnaryOperatorNode.Init(
                            ParseFactor(),
                            Lexeme."Operator Value"
                        );

                        exit(UnaryOperatorNode);
                    end;
            end;

        if PeekedLexeme.IsIdentifier() then begin
            Lexeme := AssertNextLexeme(PeekedLexeme);

            VariableNode.Init(
                Lexeme."Identifier Name"
            );

            exit(VariableNode);
        end;

        Lexeme := AssertNextLexeme(
            Lexeme.Number(0) // TODO ugly
        );

        NumberNode.Init(Lexeme."Number Value");

        exit(NumberNode);
    end;

    local procedure NextLexeme(): Record "Lexeme FS"
    var
        Lexeme: Record "Lexeme FS";
    begin
        if CachedLexeme."Entry No." <> 0 then begin
            Lexeme := CachedLexeme;
            Clear(CachedLexeme);
            exit(Lexeme);
        end;

        exit(Lexer.Next());
    end;

    local procedure PeekNextLexeme(): Record "Lexeme FS"
    begin
        if CachedLexeme."Entry No." <> 0 then
            exit(CachedLexeme);

        CachedLexeme := Lexer.Next();
        CachedLexeme."Entry No." := -1;
        exit(CachedLexeme);
    end;

    local procedure AssertNextLexeme(ExpectedLexeme: Record "Lexeme FS"): Record "Lexeme FS"
    var
        Lexeme: Record "Lexeme FS";
    begin
        Lexeme := NextLexeme();

        AssetLexeme(
            Lexeme,
            ExpectedLexeme
        );

        exit(Lexeme);
    end;

    local procedure AssetLexeme
    (
        Lexeme: Record "Lexeme FS";
        ExpectedLexeme: Record "Lexeme FS"
    )
    begin
        if Lexeme.Type <> ExpectedLexeme.Type then
            Error('AssertNextLexeme type missmatch %1 vs %2', Lexeme.Type, ExpectedLexeme.Type); // TODO

        // TODO other checks
        case ExpectedLexeme.Type of
            ExpectedLexeme.Type::Operator:
                if Lexeme."Operator Value" <> ExpectedLexeme."Operator Value" then
                    Error('AssertNextLexeme operator missmatch %1 vs %2', Lexeme."Operator Value", ExpectedLexeme."Operator Value"); // TODO
            ExpectedLexeme.Type::Keyword:
                if Lexeme."Keyword Value" <> ExpectedLexeme."Keyword Value" then
                    Error('AssertNextLexeme keyword missmatch %1 vs %2', Lexeme."Keyword Value", ExpectedLexeme."Keyword Value"); // TODO
        end;
    end;
}

interface "Node FS"
{
    procedure Visit(Memory: Codeunit "Memory FS"): Decimal;
}

codeunit 69010 "Number Node FS" implements "Node FS"
{
    var
        Number: Decimal;

    procedure Init(Value: Decimal)
    begin
        Number := Value;
    end;

    procedure Visit(Memory: Codeunit "Memory FS"): Decimal;
    begin
        exit(Number);
    end;
}

codeunit 69011 "Term Node FS" implements "Node FS"
{
    var
        Left, Right : Interface "Node FS";
        Operator: Enum "Operator FS";

    procedure Init
    (
        NewLeft: Interface "Node FS";
        NewRight: Interface "Node FS";
        NewOperator: Enum "Operator FS"
    )
    begin
        Left := NewLeft;
        Right := NewRight;
        Operator := NewOperator; // TODO validate?
    end;

    procedure Visit(Memory: Codeunit "Memory FS"): Decimal;
    begin
        case Operator of
            Operator::"*":
                exit(Left.Visit(Memory) * Right.Visit(Memory));
            Operator::"/":
                exit(Left.Visit(Memory) / Right.Visit(Memory));
            else
                Error('TODO'); // TODO
        end;
    end;
}

codeunit 69012 "Expression Node FS" implements "Node FS" // TODO merge with "Term Node"
{
    var
        Left, Right : Interface "Node FS";
        Operator: Enum "Operator FS";

    procedure Init
    (
        NewLeft: Interface "Node FS";
        NewRight: Interface "Node FS";
        NewOperator: Enum "Operator FS"
    )
    begin
        Left := NewLeft;
        Right := NewRight;
        Operator := NewOperator; // TODO validate?
    end;

    procedure Visit(Memory: Codeunit "Memory FS"): Decimal;
    begin
        case Operator of
            Operator::"+":
                exit(Left.Visit(Memory) + Right.Visit(Memory));
            Operator::"-":
                exit(Left.Visit(Memory) - Right.Visit(Memory));
            else
                Error('TODO'); // TODO
        end;
    end;
}

codeunit 69013 "Unary Operator Node FS" implements "Node FS"
{
    var
        Node: Interface "Node FS";
        Operator: Enum "Operator FS";

    procedure Init
    (
        NewNode: Interface "Node FS";
        NewOperator: Enum "Operator FS"
    )
    begin
        Node := NewNode;
        Operator := NewOperator; // TODO validate?
    end;

    procedure Visit(Memory: Codeunit "Memory FS"): Decimal;
    begin
        case Operator of
            Operator::"+":
                exit(Node.Visit(Memory));
            Operator::"-":
                exit(-Node.Visit(Memory));
            else
                Error('TODO'); // TODO
        end;
    end;
}

codeunit 69015 "NoOp FS" implements "Node FS"
{
    procedure Visit(Memory: Codeunit "Memory FS"): Decimal;
    begin
    end;
}

codeunit 69016 "Statement List FS" implements "Node FS"
{
    var
        // TODO
        Statements: array[50] of Interface "Node FS";
        StatementCount: Integer;

    procedure Add(Statement: Interface "Node FS")
    begin
        if StatementCount = ArrayLen(Statements) then
            Error('Reached maximum allowed number of statements %1.', ArrayLen(Statements));

        StatementCount += 1;
        Statements[StatementCount] := Statement;
    end;


    procedure Visit(Memory: Codeunit "Memory FS"): Decimal;
    var
        i: Integer;
    begin
        // TODO
        for i := 1 to StatementCount do
            Message('%1', Statements[i].Visit(Memory));
    end;
}

codeunit 69009 "Memory FS" // TODO or Stack/Runtime?
{
    var
        LocalVariables: array[50] of Decimal; // TODO data type
        LocalVariableCount: Integer;
        LocalVariableMap: Dictionary of [Text, Integer];

    procedure DefineLocalVariable(Name: Text)
    begin
        if LocalVariableCount = ArrayLen(LocalVariables) then
            Error('Reached maximum allowed number of local variables %1.', ArrayLen(LocalVariables));

        LocalVariableCount += 1;
        LocalVariables[LocalVariableCount] := 0;
        LocalVariableMap.Add(Name.ToLower(), LocalVariableCount); // TODO nice error if it already exists
    end;

    procedure Get(Name: Text): Decimal // TODO data type
    begin
        exit(LocalVariables[LocalVariableMap.Get(Name.ToLower())]);
    end;

    procedure Set(Name: Text; Value: Decimal) // TODO data type
    begin
        LocalVariables[LocalVariableMap.Get(Name.ToLower())] := Value;
    end;
}

codeunit 69017 "Variable Node FS" implements "Node FS"
{
    var
        Name: Text;

    procedure Init(NewName: Text)
    begin
        Name := NewName;
    end;

    procedure Visit(Memory: Codeunit "Memory FS"): Decimal;
    begin
        exit(Memory.Get(Name));
    end;
}

codeunit 69018 "Assignment Statement Node FS" implements "Node FS"
{
    var
        Expression: Interface "Node FS";
        Name: Text;

    procedure Init
    (
        NewName: Text;
        NewExpression: Interface "Node FS"
    )
    begin
        Name := NewName;
        Expression := NewExpression;
    end;

    procedure Visit(Memory: Codeunit "Memory FS"): Decimal;
    begin
        Memory.Set(
            Name,
            Expression.Visit(Memory)
        );
    end;
}