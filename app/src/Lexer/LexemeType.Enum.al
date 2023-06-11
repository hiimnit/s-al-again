enum 69001 "Lexeme Type FS"
{
    Caption = 'Lexeme Type';
    Extensible = false;

    value(0; EOS) { }
    value(1; Keyword) { }
    value(2; Operator) { }
    value(4; Identifier) { }
    value(5; Number) { }
    value(6; Bool) { }
    value(7; String) { }
    value(8; Char) { }

    value(10; Date) { }
    value(11; Time) { }
    value(12; DateTime) { }
}