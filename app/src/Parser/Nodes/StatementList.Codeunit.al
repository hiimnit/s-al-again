codeunit 69016 "Statement List FS" implements "Node FS"
{
    var
        Statements: array[50] of Interface "Node FS";
        StatementCount: Integer;

    procedure Add(Statement: Interface "Node FS")
    begin
        if StatementCount = ArrayLen(Statements) then
            Error('Reached maximum allowed number of statements %1.', ArrayLen(Statements));

        StatementCount += 1;
        Statements[StatementCount] := Statement;
    end;


    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        i: Integer;
    begin
        for i := 1 to StatementCount do
            Statements[i].Evaluate(Memory);
        exit(VoidValue);
    end;
}