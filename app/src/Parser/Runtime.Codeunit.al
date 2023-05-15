codeunit 69011 "Runtime FS"
{
    var
        Memory: Codeunit "Memory FS";
        MonacoEditor: ControlAddIn "Monaco Editor FS"; // TODO move behind an interface

    procedure Init
    (
        NewMemory: Codeunit "Memory FS";
        NewMonacoEditor: ControlAddIn "Monaco Editor FS"
    )
    begin
        Memory := NewMemory;
        MonacoEditor := NewMonacoEditor;
    end;

    procedure GetMemory(): Codeunit "Memory FS"
    begin
        exit(Memory);
    end;

    procedure WriteLine(Text: Text)
    begin
        MonacoEditor.WriteLine(Text);
    end;
}