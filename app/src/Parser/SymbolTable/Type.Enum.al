enum 69005 "Type FS"
{
    Caption = 'Type';
    Extensible = false;

    value(0; Void) { }
    value(10; Number) { }
    value(20; Boolean) { }
    value(30; Text) { }
    value(40; Record) { }

    // TODO this does not seem right
    value(100; "Return Value") { }
    value(101; "Default Return Value") { }

    value(200; Any) { }
}