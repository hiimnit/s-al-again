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
    end;

    procedure WriteLine(Text: Text)
    begin
        MonacoEditor.WriteLine(Text);
    end;

    var
        Functions: array[50] of Codeunit "User Function FS";
        FunctionMap: Dictionary of [Text[120], Integer];
        FunctionCount: Integer;

    procedure DefineFunction
    (
        UserFunction: Codeunit "User Function FS"
    )
    begin
        if FunctionCount = ArrayLen(Functions) then
            Error('Reached maximum allowed number of local functions %1.', ArrayLen(Functions));

        FunctionCount += 1;
        FunctionMap.Add(UserFunction.GetName().ToLower(), FunctionCount);
        Functions[FunctionCount] := UserFunction;
    end;

    procedure LookupFunction(Name: Text[120]): Interface "Function FS"
    var
        i: Integer;
    begin
        if FunctionMap.ContainsKey(Name.ToLower()) then begin
            i := FunctionMap.Get(Name.ToLower());
            exit(Functions[i]);
        end;

        exit(LookupBuiltInFunction(Name));
    end;

    local procedure LookupBuiltInFunction(Name: Text[120]): Interface "Function FS"
    var
        AbsFunction: Codeunit "Abs Function FS";
        PowerFunction: Codeunit "Power Function FS";
        MessageFunction: Codeunit "Message Function FS";
        ErrorFunction: Codeunit "Error Function FS";
        WriteLineFunction: Codeunit "Write Line Function FS";
        FormatFunction: Codeunit "Format Function FS";
    begin
        case Name.ToLower() of
            AbsFunction.GetName().ToLower():
                exit(AbsFunction);
            PowerFunction.GetName().ToLower():
                exit(PowerFunction);
            MessageFunction.GetName().ToLower():
                exit(MessageFunction);
            ErrorFunction.GetName().ToLower():
                exit(ErrorFunction);
            WriteLineFunction.GetName().ToLower():
                exit(WriteLineFunction);
            FormatFunction.GetName().ToLower():
                exit(FormatFunction);
            else
                Error('Function %1 does not exist.', Name);
        end;
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

        // TODO investigate - clear caused issues here, BC does not count references properly?
        // Clear(MemoryStack[MemoryCounter]);
        MemoryCounter -= 1;
    end;

    procedure GetMemory(): Codeunit "Memory FS"
    begin
        exit(MemoryStack[MemoryCounter]);
    end;

    procedure LookupMethod
    (
        Type: Enum "Type FS";
        Name: Text[120]
    ): Interface "Method FS"
    begin
        case Type of
            Type::Text:
                exit(LookupTextMethod(Name));
            else
                Error('Unknown %1 method %2.', Type, Name);
        end;
    end;

    procedure LookupTextMethod
    (
        Name: Text[120]
    ): Interface "Method FS"
    var
        TextToUpper: Codeunit "Text ToUpper FS";
        TextToLower: Codeunit "Text ToLower FS";
        TextContains: Codeunit "Text Contains FS";
    begin
        case Name.ToLower() of
            TextToUpper.GetName().ToLower():
                exit(TextToUpper);
            TextToLower.GetName().ToLower():
                exit(TextToLower);
            TextContains.GetName().ToLower():
                exit(TextContains);
            else
                Error('Unknown Text method %1.', Name);
        end;
    end;
}