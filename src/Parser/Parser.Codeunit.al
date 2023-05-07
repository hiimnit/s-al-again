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

interface "Node FS"
{
    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
}

codeunit 69010 "Literal Value Node FS" implements "Node FS"
{
    var
        LiteralValue: Interface "Value FS";

    procedure Init(Value: Decimal)
    var
        NumericValue: Codeunit "Numeric Value FS";
    begin
        NumericValue.SetValue(Value);
        LiteralValue := NumericValue;
    end;

    procedure Init(Value: Boolean)
    var
        BooleanValue: Codeunit "Boolean Value FS";
    begin
        BooleanValue.SetValue(Value);
        LiteralValue := BooleanValue;
    end;

    procedure Init(Value: Text)
    var
        TextValue: Codeunit "Text Value FS";
    begin
        TextValue.SetValue(Value);
        LiteralValue := TextValue;
    end;

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    begin
        exit(LiteralValue);
    end;
}

codeunit 69012 "Binary Operator Node FS" implements "Node FS"
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

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        LeftValueVariant, RightValueVariant : Variant;
    begin
        LeftValueVariant := Left.Evaluate(Memory).GetValue();
        RightValueVariant := Right.Evaluate(Memory).GetValue();

        case true of
            LeftValueVariant.IsDecimal() and RightValueVariant.IsDecimal():
                exit(EvaluateNumeric(LeftValueVariant, RightValueVariant));
            LeftValueVariant.IsBoolean() and RightValueVariant.IsBoolean():
                exit(EvaluateBoolean(LeftValueVariant, RightValueVariant));
            LeftValueVariant.IsText() and RightValueVariant.IsText():
                exit(EvaluateText(LeftValueVariant, RightValueVariant));
            LeftValueVariant.IsText() and RightValueVariant.IsDecimal(),
            LeftValueVariant.IsDecimal() and RightValueVariant.IsText():
                exit(EvaluateTextMultiplication(LeftValueVariant, RightValueVariant));
            else
                Error('Unimplemented binary operator input types.'); // TODO
        end;
    end;

    local procedure EvaluateNumeric
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant
    ): Interface "Value FS";
    var
        NumericValue: Codeunit "Numeric Value FS";
        LeftValue, RightValue, Result : Decimal;
    begin
        LeftValue := LeftValueVariant;
        RightValue := RightValueVariant;

        case Operator of
            Operator::"+":
                Result := LeftValue + RightValue;
            Operator::"-":
                Result := LeftValue - RightValue;
            Operator::"*":
                Result := LeftValue * RightValue;
            Operator::"/":
                Result := LeftValue / RightValue;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        NumericValue.SetValue(Result);
        exit(NumericValue);
    end;

    local procedure EvaluateBoolean
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant
    ): Interface "Value FS";
    var
        BooleanValue: Codeunit "Boolean Value FS";
        LeftValue, RightValue, Result : Boolean;
    begin
        LeftValue := LeftValueVariant;
        RightValue := RightValueVariant;

        case Operator of
            Operator::"or":
                Result := LeftValue or RightValue;
            Operator::"and":
                Result := LeftValue and RightValue;
            Operator::"xor":
                Result := LeftValue xor RightValue;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        BooleanValue.SetValue(Result);
        exit(BooleanValue);
    end;

    local procedure EvaluateText
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant
    ): Interface "Value FS";
    var
        TextValue: Codeunit "Text Value FS";
        LeftValue, RightValue, Result : Text;
    begin
        LeftValue := LeftValueVariant;
        RightValue := RightValueVariant;

        case Operator of
            Operator::"+":
                Result := LeftValue + RightValue;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        TextValue.SetValue(Result);
        exit(TextValue);
    end;

    local procedure EvaluateTextMultiplication
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant
    ): Interface "Value FS";
    var
        TextValue: Codeunit "Text Value FS";
        Text: Text;
        Number: Decimal;
        i: Integer;
        ResultBuilder: TextBuilder;
    begin
        case true of
            LeftValueVariant.IsText() and RightValueVariant.IsDecimal():
                begin
                    Text := LeftValueVariant;
                    Number := RightValueVariant;
                end;
            LeftValueVariant.IsDecimal() and RightValueVariant.IsText():
                begin
                    Number := LeftValueVariant;
                    Text := RightValueVariant;
                end;
            else
                Error('Invalid argument types.');
        end;


        case Operator of
            Operator::"*":
                // TODO check negative number?
                for i := 1 to Number do
                    ResultBuilder.Append(Text);
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        TextValue.SetValue(ResultBuilder.ToText());
        exit(TextValue);
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

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        ValueVariant: Variant;
    begin
        ValueVariant := Node.Evaluate(Memory).GetValue();

        case Operator of
            Operator::"+",
            Operator::"-":
                exit(EvaluateNumeric(ValueVariant));
            Operator::"not":
                exit(EvaluateBoolean(ValueVariant));
            else
                Error('Unimplemented unary operator %1.', Operator); // TODO
        end;
    end;

    local procedure EvaluateNumeric(ValueVariant: Variant): Interface "Value FS";
    var
        NumericValue: Codeunit "Numeric Value FS";
        Value, Result : Decimal;
    begin
        Value := ValueVariant; // TODO runtime type checking?

        case Operator of
            Operator::"+":
                Result := Value;
            Operator::"-":
                Result := -Value;
            else
                Error('Unimplemented unary operator %1.', Operator); // TODO
        end;

        NumericValue.SetValue(Result);
        exit(NumericValue);
    end;

    local procedure EvaluateBoolean(ValueVariant: Variant): Interface "Value FS";
    var
        BooleanValue: Codeunit "Boolean Value FS";
        Value, Result : Boolean;
    begin
        Value := ValueVariant; // TODO runtime type checking?

        case Operator of
            Operator::"not":
                Result := not Value;
            else
                Error('Unimplemented unary operator %1.', Operator); // TODO
        end;

        BooleanValue.SetValue(Result);
        exit(BooleanValue);
    end;
}

codeunit 69015 "NoOp FS" implements "Node FS"
{
    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
    begin
        exit(VoidValue);
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


    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        i: Integer;
    begin
        for i := 1 to StatementCount do
            Statements[i].Evaluate(Memory);
        exit(VoidValue);
    end;
}

interface "Value FS"
{
    procedure GetValue(): Variant;
    procedure SetValue(NewValue: Variant);
}

codeunit 69100 "Void Value FS" implements "Value FS"
{
    SingleInstance = true;

    procedure GetValue(): Variant;
    begin
        Error('Cannot get value of void.');
    end;

    procedure SetValue(NewValue: Variant);
    begin
        Error('Cannot set value of void.');
    end;
}

codeunit 69101 "Numeric Value FS" implements "Value FS"
{
    var
        Value: Decimal;

    procedure GetValue(): Variant;
    begin
        exit(Value);
    end;

    procedure SetValue(NewValue: Variant);
    begin
        // TODO runtime data type checking?
        Value := NewValue;
    end;
}

codeunit 69102 "Boolean Value FS" implements "Value FS"
{
    var
        Value: Boolean;

    procedure GetValue(): Variant;
    begin
        exit(Value);
    end;

    procedure SetValue(NewValue: Variant);
    begin
        // TODO runtime data type checking?
        Value := NewValue;
    end;
}

codeunit 69103 "Text Value FS" implements "Value FS"
{
    var
        Value: Text;

    procedure GetValue(): Variant;
    begin
        exit(Value);
    end;

    procedure SetValue(NewValue: Variant);
    begin
        // TODO runtime data type checking?
        Value := NewValue;
    end;
}

codeunit 69009 "Memory FS" // TODO or Stack/Runtime?
{
    var
        LocalVariables: array[50] of Interface "Value FS";
        LocalVariableCount: Integer;
        LocalVariableMap: Dictionary of [Text, Integer];

    procedure DefineLocalVariable
    (
        Name: Text;
        Type: Enum "Built-in Type FS"
    )
    var
        NumericValue: Codeunit "Numeric Value FS";
        BooleanValue: Codeunit "Boolean Value FS";
        TextValue: Codeunit "Text Value FS";
    begin
        if LocalVariableCount = ArrayLen(LocalVariables) then
            Error('Reached maximum allowed number of local variables %1.', ArrayLen(LocalVariables));

        LocalVariableCount += 1;
        LocalVariableMap.Add(Name.ToLower(), LocalVariableCount); // TODO nice error if it already exists

        case Type of
            Type::Number:
                LocalVariables[LocalVariableCount] := NumericValue;
            Type::Boolean:
                LocalVariables[LocalVariableCount] := BooleanValue;
            Type::Text:
                LocalVariables[LocalVariableCount] := TextValue;
            else
                Error('Unimplemented built-in type initilization %1.', Type);
        end;
    end;

    procedure Get(Name: Text): Interface "Value FS"
    begin
        exit(LocalVariables[LocalVariableMap.Get(Name.ToLower())]);
    end;

    procedure Set(Name: Text; Value: Interface "Value FS")
    begin
        LocalVariables[LocalVariableMap.Get(Name.ToLower())] := Value;
    end;

    procedure DebugMessage()
    var
        TextBuilder: TextBuilder;
        k: Text;
    begin
        TextBuilder.Append('Memory:\\');
        foreach k in LocalVariableMap.Keys() do
            TextBuilder.Append(StrSubstNo('%1: %2\', k, LocalVariables[LocalVariableMap.Get(k)].GetValue()));
        Message(TextBuilder.ToText());
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

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
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

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
    begin
        Memory.Set(
            Name,
            Expression.Evaluate(Memory)
        );

        exit(VoidValue);
    end;
}

enum 69004 "Built-in Type FS"
{
    Caption = 'Built-in Type';
    Extensible = false;

    value(1; Number) { }
    value(2; Boolean) { }
    value(3; Text) { }
}