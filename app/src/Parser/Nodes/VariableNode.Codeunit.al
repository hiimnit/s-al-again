codeunit 69017 "Variable Node FS" implements "Node FS"
{
    var
        Name: Text[120];

    procedure Init(NewName: Text[120])
    begin
        Name := NewName;
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    begin
        exit(Runtime.GetMemory().Get(Name));
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    begin
        exit(SymbolTable.Lookup(Name));
    end;
}