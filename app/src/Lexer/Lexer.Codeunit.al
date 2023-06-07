codeunit 69000 "Lexer FS"
{
    // TODO error shows incorrect position!

    var
        Lines: List of [Text];
        CurrentLine, CurrentChar : Integer;
        OperatorMap: Dictionary of [Text, Enum "Operator FS"];
        KeywordOperatorMap: Dictionary of [Text, Enum "Operator FS"];
        KeywordMap: Dictionary of [Text, Enum "Keyword FS"];

    procedure Init(Input: Text)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        Lines := Input.Split(TypeHelper.LFSeparator());

        CurrentLine := 1;
        CurrentChar := 1;

        InitOperatorMap();
        InitKeywordOperatorMap();
        InitKeywordMap();
    end;

    local procedure InitOperatorMap()
    begin
        OperatorMap.Add('+', Enum::"Operator FS"::"+");
        OperatorMap.Add('-', Enum::"Operator FS"::"-");
        OperatorMap.Add('*', Enum::"Operator FS"::"*");
        OperatorMap.Add('/', Enum::"Operator FS"::"/");
        OperatorMap.Add('(', Enum::"Operator FS"::"(");
        OperatorMap.Add(')', Enum::"Operator FS"::")");
        OperatorMap.Add(';', Enum::"Operator FS"::";");
        OperatorMap.Add(':', Enum::"Operator FS"::":");
        OperatorMap.Add('<', Enum::"Operator FS"::"<");
        OperatorMap.Add('>', Enum::"Operator FS"::">");
        OperatorMap.Add('=', Enum::"Operator FS"::"=");
        OperatorMap.Add('.', Enum::"Operator FS"::".");
        OperatorMap.Add(',', Enum::"Operator FS"::"comma");
        OperatorMap.Add('[', Enum::"Operator FS"::"[");
        OperatorMap.Add(']', Enum::"Operator FS"::"]");

        OperatorMap.Add('+=', Enum::"Operator FS"::"+=");
        OperatorMap.Add('-=', Enum::"Operator FS"::"-=");
        OperatorMap.Add('*=', Enum::"Operator FS"::"*=");
        OperatorMap.Add('/=', Enum::"Operator FS"::"/=");
        OperatorMap.Add(':=', Enum::"Operator FS"::":=");
        OperatorMap.Add('::', Enum::"Operator FS"::"::");
        OperatorMap.Add('<>', Enum::"Operator FS"::"<>");
        OperatorMap.Add('<=', Enum::"Operator FS"::"<=");
        OperatorMap.Add('>=', Enum::"Operator FS"::">=");
    end;

    local procedure InitKeywordOperatorMap()
    begin
        KeywordOperatorMap.Add('and', Enum::"Operator FS"::"and");
        KeywordOperatorMap.Add('or', Enum::"Operator FS"::"or");
        KeywordOperatorMap.Add('xor', Enum::"Operator FS"::"xor");
        KeywordOperatorMap.Add('not', Enum::"Operator FS"::"not");

        KeywordOperatorMap.Add('div', Enum::"Operator FS"::"div");
        KeywordOperatorMap.Add('mod', Enum::"Operator FS"::"mod");
    end;

    local procedure InitKeywordMap()
    begin
        KeywordMap.Add('begin', Enum::"Keyword FS"::"begin");
        KeywordMap.Add('end', Enum::"Keyword FS"::"end");
        KeywordMap.Add('procedure', Enum::"Keyword FS"::"procedure");
        KeywordMap.Add('var', Enum::"Keyword FS"::"var");
        KeywordMap.Add('local', Enum::"Keyword FS"::"local");
        KeywordMap.Add('if', Enum::"Keyword FS"::"if");
        KeywordMap.Add('then', Enum::"Keyword FS"::"then");
        KeywordMap.Add('else', Enum::"Keyword FS"::"else");
        KeywordMap.Add('repeat', Enum::"Keyword FS"::"repeat");
        KeywordMap.Add('until', Enum::"Keyword FS"::"until");
        KeywordMap.Add('for', Enum::"Keyword FS"::"for");
        KeywordMap.Add('foreach', Enum::"Keyword FS"::"foreach");
        KeywordMap.Add('in', Enum::"Keyword FS"::"in");
        KeywordMap.Add('to', Enum::"Keyword FS"::"to");
        KeywordMap.Add('downto', Enum::"Keyword FS"::"downto");
        KeywordMap.Add('do', Enum::"Keyword FS"::"do");
        KeywordMap.Add('while', Enum::"Keyword FS"::"while");
        KeywordMap.Add('break', Enum::"Keyword FS"::"break");
        KeywordMap.Add('exit', Enum::"Keyword FS"::"exit");
        KeywordMap.Add('trigger', Enum::"Keyword FS"::"trigger");
    end;

    procedure Next(): Record "Lexeme FS"
    var
        Lexeme: Record "Lexeme FS";
        Char: Char;
    begin
        repeat
            Char := NextChar();
            if Char = Enum::"ASCII FS"::NUL.AsInteger() then
                exit(Lexeme.EOS());
        until not IsWhiteSpace(Char);

        case true of
            IsDigit(Char):
                exit(ParseNumber(Char));
            (Char = '/') and (PeekNextChar() in ['/', '*']):
                begin
                    case NextChar() of
                        '/':
                            ConsumeUntil(Enum::"ASCII FS"::LF.AsInteger());
                        '*':
                            begin
                                repeat
                                    ConsumeUntil('*');
                                    if EOS() then
                                        Error('Unexpected end of stream at line %1, character %2.', CurrentLine, CurrentChar);
                                until PeekNextChar() = '/';

                                AssertChar(NextChar(), '/');
                            end;
                    end;

                    exit(Next());
                end;
            IsOperator(Char):
                exit(ParseOperator(Char));
            else
                exit(ParseOther(Char));
        end;
    end;

    local procedure ConsumeUntil(Stop: Char)
    var
        Char: Char;
    begin
        repeat
            Char := NextChar();
        until (Char = Stop) or (Char = Enum::"ASCII FS"::NUL.AsInteger());
    end;

    local procedure TakeUntil(Stop: Char): Text
    var
        Char: Char;
        Result: TextBuilder;
    begin
        repeat
            Char := NextChar();

            if Char in [Enum::"ASCII FS"::NUL.AsInteger(), Enum::"ASCII FS"::LF.AsInteger()] then
                Error('Unexpected end of stream, expected %3 at line %1, character %2.', CurrentLine, CurrentChar, Stop);
            if Char = Stop then
                break;

            Result.Append(Char);
        until false;

        exit(Result.ToText());
    end;

    local procedure PeekNextChar(): Char
    var
        Result: Char;
        OldCurrentLine, OldCurrentChar : Integer;
    begin
        OldCurrentChar := CurrentChar;
        OldCurrentLine := CurrentLine;

        Result := NextChar();

        CurrentChar := OldCurrentChar;
        CurrentLine := OldCurrentLine;

        exit(Result);
    end;

    local procedure NextChar(): Char
    var
        Result: Char;
    begin
        if EOS() then
            exit(0);

        if CurrentChar > StrLen(Lines.Get(CurrentLine)) then begin
            CurrentChar := 1;
            CurrentLine += 1;

            if EOS() then
                exit(0);
            // return lf stripped by splitting input into lines
            exit(10);
        end;

        Result := Lines.Get(CurrentLine) [CurrentChar];
        CurrentChar += 1;

        exit(Result);
    end;

    local procedure IsDigit(Char: Char): Boolean
    begin
        exit(Char in ['0' .. '9']);
    end;

    local procedure IsOperator(Operator: Text): Boolean
    begin
        exit(OperatorMap.ContainsKey(Operator));
    end;

    local procedure IsKeywordOperator(Operator: Text): Boolean
    begin
        exit(KeywordOperatorMap.ContainsKey(Operator.ToLower()));
    end;

    local procedure GetKeywordOperator(Operator: Text): Enum "Operator FS"
    begin
        exit(KeywordOperatorMap.Get(Operator.ToLower()));
    end;

    local procedure EOS(): Boolean
    begin
        exit(CurrentLine > Lines.Count());
    end;

    local procedure IsWhiteSpace(Char: Char): Boolean
    begin
        if Char = Enum::"ASCII FS"::NUL.AsInteger() then
            exit(false);

        case Char of
            Enum::"ASCII FS"::TAB.AsInteger(),
            Enum::"ASCII FS"::LF.AsInteger(),
            Enum::"ASCII FS"::VT.AsInteger(),
            Enum::"ASCII FS"::FF.AsInteger(),
            Enum::"ASCII FS"::CR.AsInteger(),
            Enum::"ASCII FS"::space.AsInteger(),
            Enum::"ASCII FS"::NBS.AsInteger():
                exit(true);
        end;
        exit(false);
    end;

    local procedure ParseNumber(Char: Char): Record "Lexeme FS"
    var
        Lexeme, NextLexeme : Record "Lexeme FS";
        Digit, Digits : Integer;
        Number: Decimal;
        PeekedChar: Char;
        DecimalSeparatorFound: Boolean;
        DecimalPlaces: Integer;
    begin
        Number := 0;
        DecimalPlaces := 0;
        Digits := 0;

        repeat
            Evaluate(Digit, Char);
            if not DecimalSeparatorFound then begin
                Digits += 1;
                Number *= 10;
                Number += Digit;
            end else begin
                DecimalPlaces += 1;
                Number += Power(10, -DecimalPlaces) * Digit;
            end;

            PeekedChar := PeekNextChar();
            case true of
                IsDigit(PeekedChar):
                    Char := NextChar();
                (PeekedChar = '.') and not DecimalSeparatorFound:
                    begin
                        DecimalSeparatorFound := true;
                        NextChar();
                        Char := NextChar();
                        if not IsDigit(Char) then
                            Error('Unexpected character, expected a digit at line %1, character %2.', CurrentLine, CurrentChar);
                    end;
                (PeekedChar = 'D') and not DecimalSeparatorFound:
                    begin
                        NextChar();
                        PeekedChar := PeekNextChar();

                        case true of
                            PeekedChar = 'T':
                                begin
                                    NextChar();
                                    exit(Lexeme.DateTime(
                                        ParseDate(Number, Digits),
                                        0T
                                    ));
                                end;
                            IsDigit(PeekedChar):
                                begin
                                    NextLexeme := ParseNumber(NextChar());
                                    if NextLexeme.Type <> NextLexeme.Type::Time then
                                        Error(
                                            'Expected time at line %1, characted %2, instead found %3.',
                                            CurrentLine,
                                            CurrentChar,
                                            NextLexeme.Type
                                        );

                                    exit(Lexeme.DateTime(
                                        ParseDate(Number, Digits),
                                        NextLexeme."Time Value"
                                    ));
                                end;
                            else
                                exit(Lexeme.Date(ParseDate(Number, Digits)));
                        end;
                    end;
                PeekedChar = 'T':
                    begin
                        NextChar();
                        exit(Lexeme.Time(ParseTime(Number, Digits, DecimalPlaces)));
                    end;
                else
                    exit(Lexeme.Number(Number));
            end;
        until false;
    end;

    local procedure ParseDate(Number: Decimal; Digits: Integer): Date
    var
        Years, Months, Days : Integer;
        Date: Date;
    begin
        if (Digits <> 8) and ((Digits <> 1) or (Number <> 0)) then
            Error('Invalid date: Number %1 format must be yyyymmddD or 0D.', Number);

        if Number <> Round(Number, 1) then
            Error('Invalid date: Number %1 must be an integer.', Number);

        if Digits = 1 then
            exit(0D);

        Years := Number div 10000;
        Number := Number mod 10000;
        Months := Number div 100;
        Number := Number mod 100;
        Days := Number;

        Date := DMY2Date(Days, Months, Years);

        exit(Date);
    end;

    local procedure ParseTime(Number: Decimal; Digits: Integer; DecimalPlaces: Integer): Time
    var
        Hours, Minutes, Seconds, Milliseconds : Integer;
        OriginalNumber: Decimal;
        Time: Time;
    begin
        if not IsValidTimeLiteralFormat(Number, Digits, DecimalPlaces) then
            Error('Invalid time: Number %1 format must be one of hhmmssT/hhmmss.mT/hhmmss.mmT/hhmmss.mmmT/0T.', Number);

        if Digits = 1 then
            exit(0T);

        OriginalNumber := Number;

        Hours := Number div 10000;
        Number := Number mod 10000;
        Minutes := Number div 100;
        Number := Number mod 100;
        Seconds := Number div 1;
        Number := Number mod 1;
        Milliseconds := Number * 1000;

        if not (Hours in [0 .. 23])
            or not (Minutes in [0 .. 59])
            or not (Seconds in [0 .. 59])
            or not (Milliseconds in [0 .. 999])
        then
            Error('Invalid time: Number %1 is not a valid time.', OriginalNumber);

        Time := 000000T
            + Hours * 60 * 60 * 1000
            + Minutes * 60 * 1000
            + Seconds * 1000
            + Milliseconds;

        exit(Time);
    end;

    local procedure IsValidTimeLiteralFormat(Number: Decimal; Digits: Integer; DecimalPlaces: Integer): Boolean
    begin
        if not ((Digits = 6) or ((Digits = 1) and (Number = 0))) then
            exit(false);

        if DecimalPlaces > 3 then
            exit(false);

        exit(true);
    end;

    local procedure ParseOperator(Char: Char): Record "Lexeme FS"
    var
        Lexeme: Record "Lexeme FS";
        PeekedChar: Char;
        Operator: Text;
    begin
        Operator := Char;

        PeekedChar := PeekNextChar();
        case Char of
            '+',
            '-',
            '*',
            '/',
            '>':
                if PeekedChar = '=' then
                    Operator += NextChar();
            ':':
                case PeekedChar of
                    ':',
                    '=':
                        Operator += NextChar();
                end;
            '<':
                case PeekedChar of
                    '>',
                    '=':
                        Operator += NextChar();
                end;
        end;

        exit(Lexeme.Operator(
            OperatorMap.Get(Operator)
        ));
    end;

    local procedure ParseOther(Char: Char): Record "Lexeme FS"
    begin
        case Char of
            '''':
                exit(ParseStringLiteral(Char));
            '"':
                exit(ParseQuotedIdentifier(Char));
            else
                exit(ParseOtherKeywordOrIdentifier(Char));
        end;
    end;

    local procedure ParseStringLiteral(Char: Char): Record "Lexeme FS"
    var
        Lexeme: Record "Lexeme FS";
        StringBuilder: TextBuilder;
        String: Text;
    begin
        AssertChar(Char, '''');

        repeat
            StringBuilder.Append(TakeUntil(''''));

            if PeekNextChar() <> '''' then
                break;

            // ' is escaped, append it and continue
            StringBuilder.Append(NextChar());
        until false;

        String := StringBuilder.ToText();
        if StrLen(String) = 1 then
            exit(Lexeme.CharLiteral(String));
        exit(Lexeme.StringLiteral(String));
    end;

    local procedure ParseQuotedIdentifier(Char: Char): Record "Lexeme FS"
    var
        Lexeme: Record "Lexeme FS";
        Identifier: Text;
    begin
        AssertChar(Char, '"');

        Identifier := TakeUntil('"');

        exit(Lexeme.Identifier(Identifier));
    end;

    local procedure ParseOtherKeywordOrIdentifier(Char: Char): Record "Lexeme FS"
    var
        Lexeme: Record "Lexeme FS";
        IdentifierBuilder: TextBuilder;
        Identifier: Text;
        PeekedChar: Char;
    begin
        repeat
            IdentifierBuilder.Append(Char);

            PeekedChar := PeekNextChar();
            case true of
                PeekedChar = 0,
                PeekedChar = '"',
                IsOperator(PeekedChar),
                IsWhiteSpace(PeekedChar):
                    break;
            end;

            Char := NextChar();
        until false;

        Identifier := IdentifierBuilder.ToText();

        case true of
            Identifier.ToLower() in ['true', 'false']:
                exit(Lexeme.Bool(Identifier.ToLower() = 'true'));
            IsKeywordOperator(Identifier):
                exit(Lexeme.Operator(GetKeywordOperator(Identifier)));
            IsKeyword(Identifier):
                exit(Lexeme.Keyword(GetKeyword(Identifier)));
            else
                exit(Lexeme.Identifier(Identifier));
        end;
    end;

    local procedure IsKeyword(Identifier: Text): Boolean
    begin
        exit(KeywordMap.ContainsKey(Identifier.ToLower()));
    end;

    local procedure GetKeyword(Identifier: Text): Enum "Keyword FS"
    begin
        exit(KeywordMap.Get(Identifier.ToLower()));
    end;

    local procedure AssertChar(Char: Char; ExpectedChar: Char)
    begin
        if Char <> ExpectedChar then
            Error('Unexpected character %3, expected %4 at line %1, character %2.', CurrentLine, CurrentChar, Char, ExpectedChar);
    end;
}