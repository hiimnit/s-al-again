codeunit 69015 "NoOp FS" implements "Node FS"
{
    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
    begin
        exit(VoidValue);
    end;
}