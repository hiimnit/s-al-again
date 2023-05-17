codeunit 69011 "Runtime FS"
{
    var
        MonacoEditor: ControlAddIn "Monaco Editor FS"; // TODO move behind an interface

    procedure Init
    (
        NewMonacoEditor: ControlAddIn "Monaco Editor FS"
    )
    begin
        MonacoEditor := NewMonacoEditor;

        InitBuiltInFunctions();
    end;

    procedure WriteLine(Text: Text)
    begin
        MonacoEditor.WriteLine(Text);
    end;

    var
        Functions: array[50] of Interface "Function FS";
        FunctionMap: Dictionary of [Text[120], Integer];
        FunctionCount: Integer;

    local procedure InitBuiltInFunctions()
    var
        AbsFunction: Codeunit "Abs Function FS";
        PowerFunction: Codeunit "Power Function FS";
        MessageFunction: Codeunit "Message Function FS";
        ErrorFunction: Codeunit "Error Function FS";
        WriteLineFunction: Codeunit "Write Line Function FS";
    begin
        DefineFunction(AbsFunction);
        DefineFunction(PowerFunction);
        DefineFunction(MessageFunction);
        DefineFunction(ErrorFunction);
        DefineFunction(WriteLineFunction);
    end;

    procedure DefineFunction
    (
        Function: Interface "Function FS"
    )
    begin
        // TODO check length and name uniqueness?
        FunctionCount += 1;
        FunctionMap.Add(Function.GetName().ToLower(), FunctionCount);
        Functions[FunctionCount] := Function;
    end;

    procedure LookupFunction(Name: Text[120]): Interface "Function FS"
    var
        i: Integer;
    begin
        if not FunctionMap.ContainsKey(Name.ToLower()) then
            Error('Function %1 does not exist.', Name);

        i := FunctionMap.Get(Name.ToLower());
        exit(Functions[i]);
    end;

    procedure LookupEntryPoint(): Interface "Function FS"
    begin
        exit(LookupFunction('OnRun'));
    end;

    procedure ValidateFunctionsSemantics(Self: Codeunit "Runtime FS")
    var
        FunctionIndex: Integer;
    begin
        foreach FunctionIndex in FunctionMap.Values() do
            Functions[FunctionIndex].ValidateSemantics(Self);
    end;

    var
        MemoryStack: array[50] of Codeunit "Memory FS";
        MemoryCounter: Integer;

    procedure PushMemory(Memory: Codeunit "Memory FS")
    begin
        if MemoryCounter = ArrayLen(MemoryStack) then
            Error('Reached maximum allowed number of stack frames %1.', ArrayLen(MemoryStack));

        MemoryCounter += 1;
        MemoryStack[MemoryCounter] := Memory;
    end;

    procedure PopMemory(): Codeunit "Memory FS"
    begin
        if MemoryCounter = 0 then
            Error('There is nothing to pop.');

        Clear(MemoryStack[MemoryCounter]); // FIXME test this - looks like this also clears everything in memory array? -> remove?
        MemoryCounter -= 1;
    end;

    procedure GetMemory(): Codeunit "Memory FS"
    begin
        exit(MemoryStack[MemoryCounter]);
    end;
}