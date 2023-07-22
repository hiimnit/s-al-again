enum 69007 "Parser State FS"
{
    Caption = 'Parser State';
    Extensible = false;

    value(0; None) { Caption = 'None'; }
    value(1; VarOrIdentifier) { Caption = 'VarOrIdentifier'; }
    value(2; Identifier) { Caption = 'Identifier'; }
    value(3; Type) { Caption = 'Type'; }
    value(4; SubtypeOf) { Caption = 'SubtypeOf'; }
    value(5; TypeLength) { Caption = 'TypeLength'; }
    value(6; Statement) { Caption = 'Statement'; }
    value(7; Expression) { Caption = 'Expression'; }
    value(8; PropsOf) { Caption = 'PropsOf'; }
    value(9; ProcedureOrTrigger) { Caption = 'ProcedureOrTrigger'; }
    value(10; VarOrBegin) { Caption = 'VarOrBegin'; }
    value(11; IdentifierOrBegin) { Caption = 'IdentifierOrBegin'; }
    value(99; Unfinished) { Caption = 'Unfinished'; }
}