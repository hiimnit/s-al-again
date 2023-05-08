enum 69003 "Operator FS"
{
    Caption = 'Operator';
    Extensible = false;

    value(0; " ") { }

    value(1; "+") { }
    value(2; "-") { }
    value(3; "*") { }
    value(4; "/") { }

    value(10; "(") { }
    value(11; ")") { }
    value(12; ";") { }
    value(13; ":") { }
    value(14; "<") { }
    value(15; ">") { }
    value(17; "=") { }
    value(18; ".") { }
    value(19; "comma") { }
    value(20; "[") { }
    value(21; "]") { }

    value(1000; "+=") { }
    value(1001; "-=") { }
    value(1002; "*=") { }
    value(1003; "/=") { }
    value(1004; ":=") { }
    value(1005; "::") { } // unimplemented
    value(1006; "<>") { } // unimplemented
    value(1007; "<=") { } // unimplemented
    value(1008; ">=") { } // unimplemented

    value(10000; "and") { }
    value(10001; "or") { }
    value(10002; "xor") { }
    value(10003; "not") { }

    value(20000; "div") { }
    value(20001; "mod") { }
}