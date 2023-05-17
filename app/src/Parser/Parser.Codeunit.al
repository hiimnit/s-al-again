codeunit 69001 "Parser FS"
{
    var
        CachedLexeme: Record "Lexeme FS";
        Lexer: Codeunit "Lexer FS";

    procedure Init(Input: Text)
    begin
        Lexer.Init(Input);
    end;

    procedure Parse(MonacoEditor: ControlAddIn "Monaco Editor FS"): Interface "Node FS"
    var
        Lexeme: Record "Lexeme FS";
        Runtime: Codeunit "Runtime FS";
        EmptyValueLinkedList: Codeunit "Value Linked List FS";
        Function: Interface "Function FS";
    begin
        ParseFunctions(Runtime);

        AssertNextLexeme(Lexeme.EOS());

        Runtime.Init(MonacoEditor);

        Runtime.ValidateFunctionsSemantics(Runtime);

        Function := Runtime.LookupEntryPoint();
        Function.Evaluate(Runtime, EmptyValueLinkedList);
    end;

    local procedure ParseFunctions(Runtime: Codeunit "Runtime FS")
    var
        PeekedLexeme: Record "Lexeme FS";
        Function: Interface "Function FS";
    begin
        while true do begin
            PeekedLexeme := PeekNextLexeme();
            if PeekedLexeme.IsEOS() then
                break;

            case true of
                PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"procedure"):
                    Function := ParseProcedure();
                PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"trigger"):
                    Function := ParseOnRun();
                else
                    Error('Expected keyword ''procedure'' or ''trigger''');
            end;

            Runtime.DefineFunction(
                Function
            );
        end;
    end;

    local procedure ParseOnRun(): Interface "Function FS"
    var
        Lexeme: Record "Lexeme FS";
        SymbolTable: Codeunit "Symbol Table FS";
        UserFunction: Codeunit "User Function FS";
        Statements: Interface "Node FS";
        Name: Text[120];
    begin
        AssertNextLexeme(Lexeme.Keyword(Enum::"Keyword FS"::"trigger"));

        Lexeme := AssertNextLexeme(Lexeme.Identifier());
        if Lexeme."Identifier Name".ToLower() <> 'onrun' then
            Error('Trigger must be named ''OnRun''');
        Name := Lexeme."Identifier Name";

        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::"("));
        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::")"));

        Statements := ParseProcedure(SymbolTable);

        UserFunction.Init(
            Name,
            SymbolTable,
            Statements,
            Enum::"Type FS"::Void
        );
        exit(UserFunction);
    end;

    local procedure ParseProcedure(): Interface "Function FS"
    var
        PeekedLexeme, Lexeme, ParameterNameLexeme, ParameterTypeLexeme : Record "Lexeme FS";
        SymbolTable: Codeunit "Symbol Table FS";
        UserFunction: Codeunit "User Function FS";
        Statements: Interface "Node FS";
        Name: Text[120];
    begin
        AssertNextLexeme(Lexeme.Keyword(Enum::"Keyword FS"::"procedure"));

        Lexeme := AssertNextLexeme(Lexeme.Identifier());
        Name := Lexeme."Identifier Name";

        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::"("));

        PeekedLexeme := PeekNextLexeme();
        if not PeekedLexeme.IsOperator(Enum::"Operator FS"::")") then
            while true do begin
                ParameterNameLexeme := AssertNextLexeme(Lexeme.Identifier());
                AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::":"));

                ParameterTypeLexeme := AssertNextLexeme(Lexeme.Identifier());

                SymbolTable.DefineParameter(
                    ParameterNameLexeme."Identifier Name",
                    ParseType(ParameterTypeLexeme."Identifier Name")
                );

                PeekedLexeme := PeekNextLexeme();
                if PeekedLexeme.IsOperator(Enum::"Operator FS"::")") then
                    break;

                AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::";"));
            end;

        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::")"));

        Statements := ParseProcedure(SymbolTable);

        UserFunction.Init(
            Name,
            SymbolTable,
            Statements,
            Enum::"Type FS"::Void // TODO next step - return values
        );
        exit(UserFunction);
    end;

    local procedure ParseProcedure
    (
        SymbolTable: Codeunit "Symbol Table FS"
    ): Interface "Node FS"
    var
        Lexeme, PeekedLexeme : Record "Lexeme FS";
        CompoundStatement: Interface "Node FS";
        VariableName: Text[120];
        VariableType: Enum "Type FS";
    begin
        PeekedLexeme := PeekNextLexeme();
        if PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"var") then begin
            AssertNextLexeme(PeekedLexeme);

            while true do begin
                PeekedLexeme := PeekNextLexeme();
                if not PeekedLexeme.IsIdentifier() then
                    break;

                Lexeme := NextLexeme();
                VariableName := Lexeme."Identifier Name";

                AssertNextLexeme(
                    Lexeme.Operator(Enum::"Operator FS"::":")
                );

                Lexeme := AssertNextLexeme(Lexeme.Identifier());
                VariableType := ParseType(Lexeme."Identifier Name");

                SymbolTable.DefineLocal(
                    VariableName,
                    VariableType
                );

                AssertNextLexeme(
                    Lexeme.Operator(Enum::"Operator FS"::";")
                );
            end;
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
        IdentifierName: Text[120];
        DownToLoop: Boolean;
    begin
        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"for")
        );

        IdentifierName := AssertNextLexeme(Lexeme.Identifier())."Identifier Name";

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
            Statement,
            Expression
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
            Statement,
            Expression
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

    // TODO rename
    local procedure ParseAssignmentStatement(): Interface "Node FS"
    var
        Lexeme, OperatorLexeme : Record "Lexeme FS";
        AssignmentStatementNode: Codeunit "Assignment Statement Node FS";
    begin
        Lexeme := AssertNextLexeme(Lexeme.Identifier());

        OperatorLexeme := PeekNextLexeme();
        if OperatorLexeme.IsOperator(Enum::"Operator FS"::"(") then
            exit(ParseCall(Lexeme));

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

        AssertNextLexeme(PeekNextLexeme());

        AssignmentStatementNode.Init(
            Lexeme."Identifier Name",
            ParseExpression(),
            OperatorLexeme."Operator Value"
        );

        exit(AssignmentStatementNode);
    end;

    local procedure ParseExpression(): Interface "Node FS"
    begin
        exit(ParseComparison());
    end;

    local procedure ParseComparison(): Interface "Node FS"
    var
        PeekedLexeme, Lexeme : Record "Lexeme FS";
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        Term: Interface "Node FS";
    begin
        Term := ParseTerm();

        while true do begin
            PeekedLexeme := PeekNextLexeme();

            if (PeekedLexeme.Type <> PeekedLexeme.Type::Operator)
                or not (PeekedLexeme."Operator Value" in [
                    PeekedLexeme."Operator Value"::"<",
                    PeekedLexeme."Operator Value"::"<=",
                    PeekedLexeme."Operator Value"::"<>",
                    PeekedLexeme."Operator Value"::">=",
                    PeekedLexeme."Operator Value"::">",
                    PeekedLexeme."Operator Value"::"="
                ])
            then
                break;

            Lexeme := NextLexeme();

            Clear(BinaryOperatorNode); // create new instance
            BinaryOperatorNode.Init(
                Term,
                ParseTerm(),
                Lexeme."Operator Value"
            );
            Term := BinaryOperatorNode;
        end;

        exit(Term);
    end;

    local procedure ParseTerm(): Interface "Node FS"
    var
        PeekedLexeme, Lexeme : Record "Lexeme FS";
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        Factor: Interface "Node FS";
    begin
        Factor := ParseFactor();

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
                Factor,
                ParseFactor(),
                Lexeme."Operator Value"
            );
            Factor := BinaryOperatorNode;
        end;

        exit(Factor);
    end;

    local procedure ParseFactor(): Interface "Node FS"
    var
        PeekedLexeme, Lexeme : Record "Lexeme FS";
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        Unary: Interface "Node FS";
    begin
        Unary := ParseUnary();

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
                Unary,
                ParseUnary(),
                Lexeme."Operator Value"
            );
            Unary := BinaryOperatorNode;
        end;

        exit(Unary);
    end;

    local procedure ParseUnary(): Interface "Node FS"
    var
        PeekedLexeme, Lexeme : Record "Lexeme FS";
        LiteralValueNode: Codeunit "Literal Value Node FS";
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
                            ParseUnary(),
                            Lexeme."Operator Value"
                        );

                        exit(UnaryOperatorNode);
                    end;
            end;

        if PeekedLexeme.IsNumber() then begin
            Lexeme := AssertNextLexeme(PeekedLexeme);

            LiteralValueNode.Init(Lexeme."Number Value");

            exit(LiteralValueNode);
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

        exit(ParseCall(
            NextLexeme()
        ));
    end;

    local procedure ParseCall
    (
        Lexeme: Record "Lexeme FS"
    ): Interface "Node FS"
    var
        PeekedLexeme: Record "Lexeme FS";
        VariableNode: Codeunit "Variable Node FS";
        ProcedureCallNode: Codeunit "Procedure Call Node FS";
        Argument: Interface "Node FS";
    begin
        AssertLexeme(Lexeme, PeekedLexeme.Identifier());

        PeekedLexeme := PeekNextLexeme();

        if PeekedLexeme.IsOperator(Enum::"Operator FS"::"(") then begin
            AssertNextLexeme(PeekedLexeme);

            ProcedureCallNode.Init(Lexeme."Identifier Name");

            PeekedLexeme := PeekNextLexeme();
            if not PeekedLexeme.IsOperator(Enum::"Operator FS"::")") then
                repeat
                    Argument := ParseExpression();
                    ProcedureCallNode.AddArgument(Argument);

                    PeekedLexeme := PeekNextLexeme();
                    if not PeekedLexeme.IsOperator(Enum::"Operator FS"::"comma") then
                        break;

                    AssertNextLexeme(PeekedLexeme.Operator(Enum::"Operator FS"::"comma"));
                until false;

            AssertNextLexeme(PeekedLexeme.Operator(Enum::"Operator FS"::")"));

            exit(ProcedureCallNode);

            // TODO . or () operator
            // >>>> its basically a function invocation? but what about assignment?
            // Lexeme."Identifier Name" := Lexeme."Identifier Name".ToLower().ToUpper().PadLeft(1).PadRight(2);
        end;

        VariableNode.Init(
            Lexeme."Identifier Name"
        );

        exit(VariableNode);
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

        AssertLexeme(
            Lexeme,
            ExpectedLexeme
        );

        exit(Lexeme);
    end;

    local procedure AssertLexeme
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

    local procedure ParseType(Identifier: Text): Enum "Type FS"
    begin
        case Identifier.ToLower() of
            // TODO support standard integer and decimal types?
            'number':
                exit(Enum::"Type FS"::Number);
            // TODO support code type?
            'text':
                exit(Enum::"Type FS"::Text);
            'boolean':
                exit(Enum::"Type FS"::Boolean);
            else
                Error('Unknown type %1.', Identifier);
        end;
    end;
}