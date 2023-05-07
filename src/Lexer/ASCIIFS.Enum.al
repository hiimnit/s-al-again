enum 69000 "ASCII FS"
{
    Caption = 'ASCII';
    Extensible = false;

    value(0; NUL) { Caption = 'Null'; }
    value(9; TAB) { Caption = 'Tab'; }
    value(10; LF) { Caption = 'Line Feed'; }
    value(11; VT) { Caption = 'Vertical Tab'; }
    value(12; FF) { Caption = 'Form Feed'; }
    value(13; CR) { Caption = 'Carriage Return'; }
    value(32; space) { Caption = 'Space'; }
    value(160; NBS) { Caption = 'Non Breaking Space'; }
}