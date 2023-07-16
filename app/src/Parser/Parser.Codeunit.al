codeunit 69001 "Parser FS"
{
    var
        CachedLexeme: Record "Lexeme FS";
        Lexer: Codeunit "Lexer FS";
        State: Codeunit "Parser State FS";

    procedure Parse(Input: Text; Runtime: Codeunit "Runtime FS")
    var
        Lexeme: Record "Lexeme FS";
    begin
        Lexer.Init(Input);

        ParseFunctions(Runtime);

        AssertNextLexeme(Lexeme.EOS());
    end;

    procedure ParseForIntellisense
    (
        Input: Text;
        Line: Integer;
        Column: Integer;
        Runtime: Codeunit "Runtime FS"
    ): JsonObject
    var
        Symbol: Record "Symbol FS";
        ClosestUserFunctionSignature, UserFunction : Codeunit "User Function FS";
        SymbolTable: Codeunit "Symbol Table FS";
        TextUtils: Codeunit "Text Utils FS";
        ParsingResult: JsonObject;
        LocalVariables, Functions : JsonArray;
        i: Integer;
        ClosestUserFunctionFound: Boolean;
    begin
        // first - parse function signatures and find the enclosing function
        Lexer.Init(Input);
        ClosestUserFunctionFound := ParseFunctionSignatures(Runtime, Line, Column, ClosestUserFunctionSignature);

        // second - detailed parsing of the enclosing function
        if ClosestUserFunctionFound then begin
            Clear(Lexer);
            Clear(CachedLexeme);
            Lexer.Init(TextUtils.Range(
                Input,
                ClosestUserFunctionSignature.GetStartLine(),
                ClosestUserFunctionSignature.GetStartColumn(),
                Line,
                Column
            ));

            if TryParseFunction(UserFunction) then
                // parsing went ok, function is complete
                State.ProcedureOrTrigger();

            // TODO parse with recovery
            // 1. function recovery
            // 2. variable declaration recovery
            // 3. statements recovery - use semicolons and begin/end pairs?

            if not PeekNextLexeme().IsEOS() then
                State.Unfinished();
        end else
            State.ProcedureOrTrigger();

        ParsingResult.Add('suggestions', State.ToSuggestions(Runtime, UserFunction));
        // TODO identifier suggestion lead to empty list => defaults to suggesting words?

        SymbolTable := UserFunction.GetSymbolTable();
        if SymbolTable.FindSet(Symbol) then
            repeat
                LocalVariables.Add(Symbol.ToJson());
            until not SymbolTable.Next(Symbol);
        ParsingResult.Add('localVariables', LocalVariables);

        for i := 1 to Runtime.GetFunctionCount() do begin
            // TODO skip triggers
            UserFunction := Runtime.GetFunction(i);
            Functions.Add(Runtime.CreateFunctionSymbols(
                UserFunction.GetName(),
                UserFunction.GetInsertText(),
                UserFunction.GetSignature()
            ));
        end;
        ParsingResult.Add('functions', Functions);

        // TODO unrelated - what is the result of Format(State) = formating a codeunit?

        exit(ParsingResult);
    end;

    local procedure ParseFunctionSignatures
    (
        Runtime: Codeunit "Runtime FS";
        Line: Integer;
        Column: Integer;
        var ClosestUserFunction: Codeunit "User Function FS"
    ): Boolean
    var
        PeekedLexeme: Record "Lexeme FS";
        UserFunction: Codeunit "User Function FS";
        Parsed, FunctionFound : Boolean;
    begin
        while true do begin
            PeekedLexeme := PeekNextLexeme();
            if PeekedLexeme.IsEOS() then
                break;

            if PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"procedure")
                or PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"trigger")
            then begin
                case true of
                    PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"procedure"):
                        Parsed := TryParseProcedureSignature(UserFunction);
                    PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"trigger"):
                        Parsed := TryParseOnRunSignature(UserFunction);
                    else
                        Error('Unimplemented error.');
                end;

                if Parsed then
                    Parsed := Runtime.TryDefineFunction(UserFunction);

                if UserFunction.StartsBefore(Line, Column) then begin
                    ClosestUserFunction := UserFunction;
                    FunctionFound := true;
                end;

                Clear(UserFunction);
            end else
                NextLexeme();
        end;

        exit(FunctionFound);
    end;

    local procedure ParseFunctions(Runtime: Codeunit "Runtime FS")
    var
        PeekedLexeme: Record "Lexeme FS";
        UserFunction: Codeunit "User Function FS";
    begin
        while true do begin
            State.ProcedureOrTrigger();

            PeekedLexeme := PeekNextLexeme();
            if PeekedLexeme.IsEOS() then
                break;

            case true of
                PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"procedure"):
                    UserFunction := ParseProcedure();
                PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"trigger"):
                    UserFunction := ParseOnRun();
                else
                    Error('Expected keyword ''procedure'' or ''trigger''');
            end;

            Runtime.DefineFunction(UserFunction);
        end;
    end;

    local procedure ParseOnRun(): Codeunit "User Function FS"
    var
        UserFunction: Codeunit "User Function FS";
    begin
        ParseOnRun(UserFunction);
        exit(UserFunction);
    end;

    local procedure ParseOnRun(var UserFunction: Codeunit "User Function FS")
    begin
        UserFunction := ParseOnRunSignature();
        ParseProcedureBody(UserFunction);
    end;

    [TryFunction]
    local procedure TryParseOnRunSignature(var UserFunction: Codeunit "User Function FS")
    begin
        UserFunction := ParseOnRunSignature();
    end;

    local procedure ParseOnRunSignature(): Codeunit "User Function FS"
    var
        Lexeme: Record "Lexeme FS";
        SymbolTable: Codeunit "Symbol Table FS";
        UserFunction: Codeunit "User Function FS";
        Name: Text[120];
    begin
        Lexeme := AssertNextLexeme(Lexeme.Keyword(Enum::"Keyword FS"::"trigger"));
        UserFunction.SetPositionStart(
            Lexeme."Start Line",
            Lexeme."Start Column"
        );

        State.Identifier(); // XXX OnRun is the only allowed name, suggest?

        Lexeme := AssertNextLexeme(Lexeme.Identifier());
        if Lexeme."Identifier Name".ToLower() <> 'onrun' then
            Error('Trigger must be named ''OnRun''');
        Name := Lexeme."Identifier Name";

        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::"("));
        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::")"));

        SymbolTable.DefineReturnType(SymbolTable.VoidSymbol());

        UserFunction.SetPositionEnd(
            Lexer.GetCurrentLine(),
            Lexer.GetCurrentColumn()
        );

        UserFunction.Init(
            Name,
            SymbolTable
        );
        exit(UserFunction);
    end;

    [TryFunction]
    local procedure TryParseFunction
    (
        var UserFunction: Codeunit "User Function FS"
    )
    var
        PeekedLexeme: Record "Lexeme FS";
    begin
        State.ProcedureOrTrigger();

        PeekedLexeme := PeekNextLexeme();
        if PeekedLexeme.IsEOS() then
            exit;

        case true of
            PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"procedure"):
                ParseProcedure(UserFunction);
            PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"trigger"):
                ParseOnRun(UserFunction);
            else
                Error('Expected keyword ''procedure'' or ''trigger''');
        end;
    end;

    local procedure ParseProcedure(): Codeunit "User Function FS"
    var
        UserFunction: Codeunit "User Function FS";
    begin
        ParseProcedure(UserFunction);
        exit(UserFunction);
    end;

    local procedure ParseProcedure(var UserFunction: Codeunit "User Function FS")
    begin
        ParseProcedureSignature(UserFunction);
        // FIXME
        ParseProcedureBody(UserFunction);
    end;

    [TryFunction]
    local procedure TryParseProcedureSignature(var UserFunction: Codeunit "User Function FS")
    begin
        ParseProcedureSignature(UserFunction);
    end;

    local procedure ParseProcedureSignature(var UserFunction: Codeunit "User Function FS")
    var
        PeekedLexeme, Lexeme : Record "Lexeme FS";
        ParameterSymbol, ReturnTypeSymbol : Record "Symbol FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Pointer: Boolean;
        Name: Text[120];
    begin
        Lexeme := AssertNextLexeme(Lexeme.Keyword(Enum::"Keyword FS"::"procedure"));
        UserFunction.SetPositionStart(
            Lexeme."Start Line",
            Lexeme."Start Column"
        );

        State.Identifier();

        Lexeme := AssertNextLexeme(Lexeme.Identifier());
        Name := Lexeme."Identifier Name";

        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::"("));

        PeekedLexeme := PeekNextLexeme();
        if not PeekedLexeme.IsOperator(Enum::"Operator FS"::")") then
            while true do begin
                State.VarOrIdentifier();

                Pointer := false;
                PeekedLexeme := PeekNextLexeme();
                if PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"var") then begin
                    NextLexeme();
                    Pointer := true;

                    State.Identifier();
                end;

                ParameterSymbol := ParseVariableDefinition(true);
                SymbolTable.DefineParameter(ParameterSymbol, Pointer);

                PeekedLexeme := PeekNextLexeme();
                if PeekedLexeme.IsOperator(Enum::"Operator FS"::")") then
                    break;

                AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::";"));
            end;

        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::")"));

        ReturnTypeSymbol := SymbolTable.VoidSymbol();
        PeekedLexeme := PeekNextLexeme();
        if PeekedLexeme.IsIdentifier() or PeekedLexeme.IsOperator(Enum::"Operator FS"::":") then begin
            State.Identifier();
            ReturnTypeSymbol := ParseVariableDefinition(false); // FIXME subtype is not suggested - instead keywords are shown!
        end;

        SymbolTable.DefineReturnType(ReturnTypeSymbol);

        UserFunction.SetPositionEnd(
            Lexer.GetCurrentLine(),
            Lexer.GetCurrentColumn()
        );

        UserFunction.Init(
            Name,
            SymbolTable
        );
    end;

    local procedure ParseVariableDefinition(NameRequired: Boolean): Record "Symbol FS"
    var
        Symbol: Record "Symbol FS";
        Lexeme, PeekedLexeme, NameLexeme, TypeLexeme, SubtypeLexeme : Record "Lexeme FS";
    begin
        PeekedLexeme := PeekNextLexeme();
        if NameRequired or PeekedLexeme.IsIdentifier() then begin
            NameLexeme := AssertNextLexeme(Lexeme.Identifier());
            Symbol.Name := NameLexeme."Identifier Name";
        end;

        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::":"));

        State.Type();
        TypeLexeme := AssertNextLexeme(Lexeme.Identifier());
        Symbol.Type := ParseType(TypeLexeme."Identifier Name");

        if IsSubtypeMandatory(Symbol.Type) then begin
            State.SubtypeOf(Symbol.Type);
            SubtypeLexeme := AssertNextLexeme(PeekedLexeme.Identifier());
            Symbol.Subtype := SubtypeLexeme."Identifier Name";
        end;

        PeekedLexeme := PeekNextLexeme();
        if PeekedLexeme.IsOperator(Enum::"Operator FS"::"[") then begin
            State.TypeLength();

            AssertNextLexeme(PeekedLexeme);

            Lexeme := AssertNextLexeme(PeekedLexeme.Integer());
            Symbol.SetLength(Lexeme."Integer Value");

            AssertNextLexeme(PeekedLexeme.Operator(Enum::"Operator FS"::"]"));
        end;

        exit(Symbol);
    end;

    local procedure ParseProcedureBody
    (
        UserFunction: Codeunit "User Function FS"
    )
    var
        Lexeme, PeekedLexeme : Record "Lexeme FS";
        VariableSymbol: Record "Symbol FS";
        SymbolTable: Codeunit "Symbol Table FS";
        CompoundStatement: Interface "Node FS";
    begin
        State.VarOrBegin();

        SymbolTable := UserFunction.GetSymbolTable();

        PeekedLexeme := PeekNextLexeme();
        if PeekedLexeme.IsKeyword(Enum::"Keyword FS"::"var") then begin
            AssertNextLexeme(PeekedLexeme);

            while true do begin
                State.IdentifierOrBegin();

                PeekedLexeme := PeekNextLexeme();
                if not PeekedLexeme.IsIdentifier() then
                    break;

                VariableSymbol := ParseVariableDefinition(true);
                SymbolTable.DefineLocal(VariableSymbol);

                AssertNextLexeme(
                    Lexeme.Operator(Enum::"Operator FS"::";")
                );
            end;
        end;

        CompoundStatement := ParseCompoundStatement();
        AssertNextLexeme(
            Lexeme.Operator(Enum::"Operator FS"::";")
        );

        UserFunction.SetStatements(CompoundStatement);
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
        State.PushKeyword(OpeningKeyword);

        StatementList := ParseStatementList();

        AssertNextLexeme(
            Lexeme.Keyword(ClosingKeyword)
        );
        State.PopKeyword(OpeningKeyword);

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
        State.PushKeyword(Enum::"Keyword FS"::"if");

        Expression := ParseExpression();

        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"then")
        );
        State.PopKeyword(Enum::"Keyword FS"::"if");

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
        VariableExpression, InitialValueExpression, FinalValueExpression, Statement : Interface "Node FS";
        DownToLoop: Boolean;
    begin
        AssertNextLexeme(Lexeme.Keyword(Enum::"Keyword FS"::"for"));
        State.PushKeyword(Enum::"Keyword FS"::"for");

        VariableExpression := ParseGetExpression(false);

        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::":="));

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
        State.PopKeyword(Enum::"Keyword FS"::"for");
        State.PushKeyword(Enum::"Keyword FS"::"do");

        FinalValueExpression := ParseExpression();

        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"do")
        );
        State.PopKeyword(Enum::"Keyword FS"::"do");

        Statement := ParseStatement();

        ForStatementNode.Init(
            Statement,
            VariableExpression,
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
        State.PushKeyword(Enum::"Keyword FS"::"while");

        Expression := ParseExpression();

        AssertNextLexeme(
            Lexeme.Keyword(Enum::"Keyword FS"::"do")
        );
        State.PopKeyword(Enum::"Keyword FS"::"while");

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

    local procedure ParseExitStatement(): Interface "Node FS"
    var
        Lexeme, PeekedLexeme : Record "Lexeme FS";
        ExitStatementNode: Codeunit "Exit Statement Node FS";
    begin
        Lexeme := AssertNextLexeme(Lexeme.Keyword(Enum::"Keyword FS"::"exit"));

        PeekedLexeme := PeekNextLexeme();
        if not PeekedLexeme.IsOperator(Enum::"Operator FS"::"(") then
            exit(ExitStatementNode);

        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::"("));
        ExitStatementNode.Init(
            ParseExpression()
        );
        AssertNextLexeme(Lexeme.Operator(Enum::"Operator FS"::")"));

        exit(ExitStatementNode);
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

        State.Statement();

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
            Lexeme.IsKeyword(Enum::"Keyword FS"::"exit"):
                exit(ParseExitStatement());
            Lexeme.IsIdentifier():
                exit(ParseGetExpression(true));
        end;

        exit(NoOp);
    end;

    local procedure ParseExpression(): Interface "Node FS"
    begin
        State.Expression();

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
        UnaryOperatorNode: Codeunit "Unary Operator Node FS";
        ParenthesesNode: Codeunit "Parentheses Node FS";
    begin
        PeekedLexeme := PeekNextLexeme();

        if PeekedLexeme.IsOperator() then
            case PeekedLexeme."Operator Value" of
                PeekedLexeme."Operator Value"::"(":
                    begin
                        NextLexeme();

                        ParenthesesNode.Init(ParseExpression());

                        AssertNextLexeme(
                            PeekedLexeme.Operator(Enum::"Operator FS"::")")
                        );

                        exit(ParenthesesNode);
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

        exit(ParseGetExpression(false));
    end;

    local procedure ParseCall(): Interface "Node FS"
    var
        Lexeme, PeekedLexeme : Record "Lexeme FS";
        VariableNode: Codeunit "Variable Node FS";
        ProcedureCallNode: Codeunit "Procedure Call Node FS";
        LiteralValueNode: Codeunit "Literal Value Node FS";
    begin
        Lexeme := NextLexeme();

        if Lexeme.IsLiteralValue() then begin
            case true of
                Lexeme.IsInteger():
                    LiteralValueNode.Init(Lexeme."Integer Value");
                Lexeme.IsDecimal():
                    LiteralValueNode.Init(Lexeme."Decimal Value");
                Lexeme.IsBoolean():
                    LiteralValueNode.Init(Lexeme."Boolean Value");
                Lexeme.IsString():
                    LiteralValueNode.Init(Lexeme.GetStringValue());
                Lexeme.IsChar():
                    LiteralValueNode.Init(Lexeme."Char Value"[1]);
                Lexeme.IsDate():
                    LiteralValueNode.Init(Lexeme."Date Value");
                Lexeme.IsTime():
                    LiteralValueNode.Init(Lexeme."Time Value");
                Lexeme.IsDateTime():
                    LiteralValueNode.Init(Lexeme."DateTime Value");
                else
                    Error('Literal value parsing is not implemented for %1.', Lexeme.Type);
            end;

            exit(LiteralValueNode);
        end;

        AssertLexeme(Lexeme, PeekedLexeme.Identifier());

        PeekedLexeme := PeekNextLexeme();
        if PeekedLexeme.IsOperator(Enum::"Operator FS"::"(") then begin
            ProcedureCallNode.Init(
                Lexeme."Identifier Name",
                ParseArguments()
            );

            exit(ProcedureCallNode);
        end;

        VariableNode.Init(
            Lexeme."Identifier Name"
        );

        exit(VariableNode);
    end;

    local procedure ParseGetExpression(TopLevel: Boolean): Interface "Node FS"
    var
        Lexeme, PeekedLexeme, OperatorLexeme : Record "Lexeme FS";
        MethodCallNode: Codeunit "Method Call Node FS";
        PropertyAccessNode: Codeunit "Property Access Node FS";
        IndexAccessNode: Codeunit "Index Access Node FS";
        AssignmentStatementNode: Codeunit "Assignment Statement Node FS";
        Call: Interface "Node FS";
    begin
        State.Expression(); // resets PropsOf state

        Call := ParseCall();

        while true do begin
            PeekedLexeme := PeekNextLexeme();

            case true of
                TopLevel and PeekedLexeme.IsAssignmentOperator():
                    begin
                        OperatorLexeme := AssertNextLexeme(PeekNextLexeme());

                        AssignmentStatementNode.Init(
                            Call,
                            ParseExpression(),
                            OperatorLexeme."Operator Value"
                        );

                        exit(AssignmentStatementNode);
                    end;
                PeekedLexeme.IsOperator(Enum::"Operator FS"::"."):
                    begin
                        AssertNextLexeme(PeekedLexeme);

                        State.PropsOf(Call);

                        Lexeme := AssertNextLexeme(Lexeme.Identifier());

                        PeekedLexeme := PeekNextLexeme();
                        if PeekedLexeme.IsOperator(Enum::"Operator FS"::"(") then begin
                            Clear(MethodCallNode); // create new instance
                            MethodCallNode.Init(
                                Call,
                                Lexeme."Identifier Name",
                                ParseArguments()
                            );

                            Call := MethodCallNode;
                        end else begin
                            Clear(PropertyAccessNode); // create new instance
                            PropertyAccessNode.Init(
                                Call,
                                Lexeme."Identifier Name"
                            );

                            Call := PropertyAccessNode;
                        end;
                    end;
                PeekedLexeme.IsOperator(Enum::"Operator FS"::"["):
                    begin
                        AssertNextLexeme(PeekedLexeme.Operator(Enum::"Operator FS"::"["));

                        Clear(IndexAccessNode); // create new instance
                        IndexAccessNode.Init(
                            Call,
                            ParseExpression()
                        );

                        Call := IndexAccessNode;
                        AssertNextLexeme(PeekedLexeme.Operator(Enum::"Operator FS"::"]"));
                    end;
                else
                    break;
            end;
        end;

        Call.SetTopLevel(TopLevel);

        exit(Call);
    end;

    local procedure ParseArguments(): Codeunit "Node Linked List FS";
    var
        PeekedLexeme: Record "Lexeme FS";
        Arguments: Codeunit "Node Linked List FS";
    begin
        // TODO suggest fields in methdos like setrage, setfilter, validate

        AssertNextLexeme(PeekedLexeme.Operator(Enum::"Operator FS"::"("));

        PeekedLexeme := PeekNextLexeme();
        if not PeekedLexeme.IsOperator(Enum::"Operator FS"::")") then
            repeat
                Arguments.Insert(ParseExpression());

                PeekedLexeme := PeekNextLexeme();
                if not PeekedLexeme.IsOperator(Enum::"Operator FS"::"comma") then
                    break;

                AssertNextLexeme(PeekedLexeme.Operator(Enum::"Operator FS"::"comma"));
            until false;

        AssertNextLexeme(PeekedLexeme.Operator(Enum::"Operator FS"::")"));

        exit(Arguments);
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
            Error('Expected token %1, got %2.', ExpectedLexeme.Type, Lexeme.Type);

        case ExpectedLexeme.Type of
            ExpectedLexeme.Type::Operator:
                if Lexeme."Operator Value" <> ExpectedLexeme."Operator Value" then
                    Error('Expected operator %1, got %2.', ExpectedLexeme."Operator Value", Lexeme."Operator Value");
            ExpectedLexeme.Type::Keyword:
                if Lexeme."Keyword Value" <> ExpectedLexeme."Keyword Value" then
                    Error('Expected keyword %1, got %2.', ExpectedLexeme."Keyword Value", Lexeme."Keyword Value");
        end;
    end;

    local procedure ParseType(Identifier: Text): Enum "Type FS"
    begin
        case Identifier.ToLower() of
            'integer':
                exit(Enum::"Type FS"::Integer);
            'decimal':
                exit(Enum::"Type FS"::Decimal);
            'text':
                exit(Enum::"Type FS"::Text);
            'code':
                exit(Enum::"Type FS"::Code);
            'boolean':
                exit(Enum::"Type FS"::Boolean);
            'record':
                exit(Enum::"Type FS"::Record);
            'date':
                exit(Enum::"Type FS"::Date);
            'time':
                exit(Enum::"Type FS"::Time);
            'datetime':
                exit(Enum::"Type FS"::DateTime);
            'dateformula':
                exit(Enum::"Type FS"::DateFormula);
            'guid':
                exit(Enum::"Type FS"::Guid);
            'char':
                exit(Enum::"Type FS"::Char);
            else
                Error('Unknown type %1.', Identifier);
        end;
    end;

    local procedure IsSubtypeMandatory(Type: Enum "Type FS"): Boolean
    begin
        exit(Type = Enum::"Type FS"::Record);
    end;
}