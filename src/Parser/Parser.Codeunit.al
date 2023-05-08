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

        Node.Evaluate(Memory);

        Memory.DebugMessage();
    end;

    local procedure ParseProgram
    (
        // TODO temporary solution => return a list of variables - symbol table
        // >>>> so that the interpreter can initialize them when needed
        Memory: Codeunit "Memory FS"
    ): Interface "Node FS"
    var
        Lexeme, PeekedLexeme : Record "Lexeme FS";
        CompoundStatement: Interface "Node FS";
        VariableName: Text;
        VariableType: Enum "Built-in Type FS";
    begin
        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"var")
        );

        while true do begin
            PeekedLexeme := PeekNextLexeme();
            if not PeekedLexeme.IsIdentifier() then
                break;

            Lexeme := NextLexeme();
            VariableName := Lexeme."Identifier Name";

            AssertNextLexeme(
                Lexeme.Operator(Enum::"Operator FS"::":")
            );

            Lexeme := AssertNextLexeme(
                Lexeme.Identifier('TODO') // TODO
            );
            VariableType := ParseBuiltinType(Lexeme."Identifier Name");

            // TODO variables should not be initialized here
            Memory.DefineLocalVariable(
                VariableName,
                VariableType
            );

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
    begin
        exit(ParseCompoundStatement(
            Enum::"Keyword FS"::"begin",
            Enum::"Keyword FS"::"end"
        ));
    end;

    local procedure ParseRepeatCompoundStatement(): Interface "Node FS"
    begin
        exit(ParseCompoundStatement(
            Enum::"Keyword FS"::"repeat",
            Enum::"Keyword FS"::"until"
        ));
    end;

    local procedure ParseCompoundStatement
    (
        OpeningKeyword: Enum "Keyword FS";
        ClosingKeyword: Enum "Keyword FS"
    ): Interface "Node FS"
    var
        Lexeme: Record "Lexeme FS";
        StatementList: Interface "Node FS";
    begin
        AssertNextLexeme(
            Lexeme.Keyword(OpeningKeyword)
        );

        StatementList := ParseStatementList();

        AssertNextLexeme(
            Lexeme.Keyword(ClosingKeyword)
        );

        exit(StatementList);
    end;

    local procedure ParseIfStatement(): Interface "Node FS"
    var
        Lexeme, PeekedLexeme : Record "Lexeme FS";
        IfStatementNode: Codeunit "If Statement Node FS";
        Expression, Statement, ElseStatement : Interface "Node FS";
    begin
        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"if")
        );

        Expression := ParseExpression();

        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"then")
        );

        Statement := ParseStatement();

        IfStatementNode.InitIf(
            Expression,
            Statement
        );

        PeekedLexeme := PeekNextLexeme();

        if PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"else") then begin
            AssertNextLexeme(
                Lexeme.Keyword(Enum::"Keyword FS"::"else")
            );

            ElseStatement := ParseStatement();

            IfStatementNode.InitElse(
                ElseStatement
            );
        end;

        exit(IfStatementNode);
    end;

    local procedure ParseForStatement(): Interface "Node FS"
    var
        Lexeme: Record "Lexeme FS";
        ForStatementNode: Codeunit "For Statement Node FS";
        InitialValueExpression, FinalValueExpression, Statement : Interface "Node FS";
        IdentifierName: Text;
        DownToLoop: Boolean;
    begin
        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"for")
        );

        IdentifierName := AssertNextLexeme(
            Lexeme.Identifier('TODO') // TODO
        )."Identifier Name";

        AssertNextLexeme(
            Lexeme.Operator(Enum::"Operator FS"::":=")
        );

        InitialValueExpression := ParseExpression();

        Lexeme := NextLexeme();
        case true of
            Lexeme.IsKeyword(Enum::"Keyword FS"::"to"):
                DownToLoop := false;
            Lexeme.IsKeyword(Enum::"Keyword FS"::"downto"):
                DownToLoop := true;
            else
                Error(
                    'Unexpected lexeme, expected keyword %1 or %2.',
                    Enum::"Keyword FS"::"to",
                    Enum::"Keyword FS"::"downto"
                );
        end;

        FinalValueExpression := ParseExpression();

        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"do")
        );

        Statement := ParseStatement();

        ForStatementNode.Init(
            Statement,
            IdentifierName,
            InitialValueExpression,
            FinalValueExpression,
            DownToLoop
        );

        exit(ForStatementNode);
    end;

    local procedure ParseWhileStatement(): Interface "Node FS"
    var
        Lexeme: Record "Lexeme FS";
        WhileStatementNode: Codeunit "While Statement Node FS";
        Expression, Statement : Interface "Node FS";
    begin
        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"while")
        );

        Expression := ParseExpression();

        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"do")
        );

        Statement := ParseStatement();

        WhileStatementNode.Init(
            Expression,
            Statement
        );

        exit(WhileStatementNode);
    end;

    local procedure ParseRepeatStatement(): Interface "Node FS"
    var
        RepeatStatementNode: Codeunit "Repeat Statement Node FS";
        Expression, Statement : Interface "Node FS";
    begin
        Statement := ParseRepeatCompoundStatement();

        Expression := ParseExpression();

        RepeatStatementNode.Init(
            Expression,
            Statement
        );

        exit(RepeatStatementNode);
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
            Lexeme.IsKeyword(Enum::"Keyword FS"::"if"):
                exit(ParseIfStatement());
            Lexeme.IsKeyword(Enum::"Keyword FS"::"for"):
                exit(ParseForStatement());
            Lexeme.IsKeyword(Enum::"Keyword FS"::"while"):
                exit(ParseWhileStatement());
            Lexeme.IsKeyword(Enum::"Keyword FS"::"repeat"):
                exit(ParseRepeatStatement());
            Lexeme.IsIdentifier():
                exit(ParseAssignmentStatement());
        end;

        exit(NoOp);
    end;

    local procedure ParseAssignmentStatement(): Interface "Node FS"
    var
        Lexeme, OperatorLexeme : Record "Lexeme FS";
        AssignmentStatementNode: Codeunit "Assignment Statement Node FS";
    begin
        Lexeme := AssertNextLexeme(
            Lexeme.Identifier('TODO') // TODO
        );

        OperatorLexeme := NextLexeme();
        if not OperatorLexeme.IsOperator() or
            not (OperatorLexeme."Operator Value" in [
                Enum::"Operator FS"::":=",
                Enum::"Operator FS"::"+=",
                Enum::"Operator FS"::"-=",
                Enum::"Operator FS"::"*=",
                Enum::"Operator FS"::"/="
            ])
        then
            Error('Unexpected token %1 - expected an assignment operator.', OperatorLexeme.Type);

        AssignmentStatementNode.Init(
            Lexeme."Identifier Name",
            ParseExpression(),
            OperatorLexeme."Operator Value"
        );

        exit(AssignmentStatementNode);
    end;

    local procedure ParseExpression(): Interface "Node FS"
    var
        PeekedLexeme, Lexeme : Record "Lexeme FS";
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        Expression: Interface "Node FS";
    begin
        Expression := ParseTerm();

        while true do begin
            PeekedLexeme := PeekNextLexeme();

            if (PeekedLexeme.Type <> PeekedLexeme.Type::Operator)
                or not (PeekedLexeme."Operator Value" in [
                    PeekedLexeme."Operator Value"::"+",
                    PeekedLexeme."Operator Value"::"-",
                    PeekedLexeme."Operator Value"::"or"
                ])
            then
                break;

            Lexeme := NextLexeme();

            Clear(BinaryOperatorNode); // create new instance
            BinaryOperatorNode.Init(
                Expression,
                ParseTerm(),
                Lexeme."Operator Value"
            );
            Expression := BinaryOperatorNode;
        end;

        exit(Expression);
    end;

    local procedure ParseTerm(): Interface "Node FS"
    var
        PeekedLexeme, Lexeme : Record "Lexeme FS";
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        Term: Interface "Node FS";
    begin
        Term := ParseFactor();

        while true do begin
            PeekedLexeme := PeekNextLexeme();

            if (PeekedLexeme.Type <> PeekedLexeme.Type::Operator)
                or not (PeekedLexeme."Operator Value" in [
                    PeekedLexeme."Operator Value"::"*",
                    PeekedLexeme."Operator Value"::"/",
                    PeekedLexeme."Operator Value"::"div",
                    PeekedLexeme."Operator Value"::"mod",
                    PeekedLexeme."Operator Value"::"and",
                    PeekedLexeme."Operator Value"::"xor"
                ])
            then
                break;

            Lexeme := NextLexeme();

            Clear(BinaryOperatorNode); // create new instance
            BinaryOperatorNode.Init(
                Term,
                ParseFactor(),
                Lexeme."Operator Value"
            );
            Term := BinaryOperatorNode;
        end;

        exit(Term);
    end;

    local procedure ParseFactor(): Interface "Node FS"
    var
        PeekedLexeme, Lexeme : Record "Lexeme FS";
        LiteralValueNode: Codeunit "Literal Value Node FS";
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
                PeekedLexeme."Operator Value"::"-",
                PeekedLexeme."Operator Value"::"not":
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

        if PeekedLexeme.IsBoolean() then begin
            Lexeme := AssertNextLexeme(PeekedLexeme);

            LiteralValueNode.Init(Lexeme."Boolean Value");

            exit(LiteralValueNode);
        end;

        if PeekedLexeme.IsString() then begin
            Lexeme := AssertNextLexeme(PeekedLexeme);

            LiteralValueNode.Init(Lexeme.GetStringValue());

            exit(LiteralValueNode);
        end;

        Lexeme := AssertNextLexeme(
            Lexeme.Number(0) // TODO ugly
        );

        LiteralValueNode.Init(Lexeme."Number Value");

        exit(LiteralValueNode);
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

    local procedure ParseBuiltinType(Identifier: Text): Enum "Built-in Type FS"
    begin
        case Identifier.ToLower() of
            // TODO support standard integer and decimal types?
            'number':
                exit(Enum::"Built-in Type FS"::Number);
            'text':
                exit(Enum::"Built-in Type FS"::Text);
            'boolean':
                exit(Enum::"Built-in Type FS"::Boolean);
            else
                Error('Unknown type %1.', Identifier);
        end;
    end;
}