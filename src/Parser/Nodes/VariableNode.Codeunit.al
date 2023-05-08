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