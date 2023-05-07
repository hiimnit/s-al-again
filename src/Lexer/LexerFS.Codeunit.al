codeunit 69000 "Lexer FS"
{
    var
        Lines: List of [Text];
        CurrentLine, CurrentChar : Integer;
        OperatorMap: Dictionary of [Text, Enum "Operator FS"];
        KeywordMap: Dictionary of [Text, Enum "Keyword FS"];

    procedure Init(Input: Text)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        Lines := Input.Split(TypeHelper.LFSeparator());

        // TODO remove all <CR> (13)?

        CurrentLine := 1;
        CurrentChar := 1;

        InitOperatorMap();
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

        OperatorMap.Add('and', Enum::"Operator FS"::"and");
        OperatorMap.Add('or', Enum::"Operator FS"::"or");
        OperatorMap.Add('xor', Enum::"Operator FS"::"xor");
        OperatorMap.Add('not', Enum::"Operator FS"::"not");
    end;

    local procedure InitKeywordMap()
    begin
        KeywordMap.Add('begin', Enum::"Keyword FS"::"begin");
        KeywordMap.Add('end', Enum::"Keyword FS"::"end");
        KeywordMap.Add('procedure', Enum::"Keyword FS"::"procedure");
        KeywordMap.Add('var', Enum::"Keyword FS"::"var");
        KeywordMap.Add('record', Enum::"Keyword FS"::"record");
        KeywordMap.Add('integer', Enum::"Keyword FS"::"integer");
        KeywordMap.Add('decimal', Enum::"Keyword FS"::"decimal");
        KeywordMap.Add('boolean', Enum::"Keyword FS"::"boolean");
        KeywordMap.Add('text', Enum::"Keyword FS"::"text");
        KeywordMap.Add('code', Enum::"Keyword FS"::"code");
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
                            ConsumeUntil(10); // TODO enum for ascii <LF>
                        '*':
                            repeat
                                // TODO error if eos
                                ConsumeUntil('*');
                            until (EOS()) or (PeekNextChar() = '/');
                    end;

                    exit(Next());
                end;
            IsSeparator(Char),
            IsOperator(Char):
                ;
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

            if Char = Enum::"ASCII FS"::NUL.AsInteger() then
                Error(''); // TODO EOS error
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

    // TODO
    // FIXME what about := ? and :: ?
    local procedure IsOperator(Char: Char): Boolean
    begin
        case Char of
            '+',
            '-',
            '*',
            '/',
            '=',
            '<',
            '>':
                exit(true);
        end;

        exit(false);
    end;

    local procedure IsSeparator(Char: Char): Boolean
    begin
        case Char of
            '.',
            ',',
            ':',
            ';',
            ')',
            '(',
            '[',
            ']':
                exit(true);
        end;

        exit(false);
    end;

    local procedure EOS(): Boolean
    begin
        if CurrentLine > Lines.Count() then
            exit(true);
        exit(CurrentChar > StrLen(Lines.Get(CurrentLine)));
    end;

    local procedure IsWhiteSpace(Char: Char): Boolean
    begin
        if Char = Enum::"ASCII FS"::NUL.AsInteger() then
            exit(false);

        // TODO double check
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
        Lexeme: Record "Lexeme FS";
        Digit: Integer;
        Number: Decimal;
        PeekedChar: Char;
        DecimalSeparatorFound: Boolean;
        DecimalPlaces: Integer;
    begin
        Number := 0;
        DecimalPlaces := 0;

        repeat
            Evaluate(Digit, Char);
            if not DecimalSeparatorFound then begin
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
                PeekedChar = '.':
                    begin
                        if DecimalSeparatorFound then
                            Error(''); // TODO

                        DecimalSeparatorFound := true;
                        NextChar();
                        Char := NextChar();
                        if not IsDigit(Char) then
                            Error(''); // TODO check if digit
                    end;
                PeekedChar = 0, // TODO EOS enum
                IsOperator(PeekedChar):
                    exit(Lexeme.Number(Number));
                else
                    Error(''); // TODO
            end;
        until false;
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
    begin
        AssertChar(Char, '''');

        repeat
            StringBuilder.Append(TakeUntil('''')); // TODO this allow multiline strings!

            if PeekNextChar() <> '''' then
                break;

            // ' is escaped, append it and continue
            StringBuilder.Append(NextChar());
        until false;

        exit(Lexeme.StringLiteral(StringBuilder.ToText()));
    end;

    local procedure ParseQuotedIdentifier(Char: Char): Record "Lexeme FS"
    var
        Lexeme: Record "Lexeme FS";
        Identifier: Text;
    begin
        AssertChar(Char, '"');

        Identifier := TakeUntil('"'); // TODO this allow multiline identifiers!

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
                // TODO what about new lines?
                PeekedChar = 0,
                PeekedChar = '"',
                IsSeparator(Char),
                IsOperator(Char),
                IsWhiteSpace(PeekedChar):
                    break;
            end;

            Char := NextChar();
        until false;

        Identifier := IdentifierBuilder.ToText();

        case Identifier of
            'true', 'false':
                ; // TODO boolean literal
                  // TODO check for keywords
            else
                exit(Lexeme.Identifier(Identifier));
        end;
    end;

    local procedure AssertChar(Char: Char; ExpectedChar: Char)
    var
        myInt: Integer;
    begin
        Error(''); // TODO
    end;
}