codeunit 69004 "Text Utils FS"
{
    procedure Range
    (
        Input: Text;
        StartLine: Integer;
        StartColumn: Integer;
        EndLine: Integer;
        EndColumn: Integer
    ): Text
    var
        TypeHelper: Codeunit "Type Helper";
        TextLines: List of [Text];
        RangeBuilder: TextBuilder;
        i: Integer;
    begin
        if StartLine > EndLine then
            Error('Invalid arguments: StartLine must be lower or equal to EndLine.');

        TextLines := Input.Split(TypeHelper.LFSeparator());

        if StartLine = EndLine then begin
            if StartColumn > EndColumn then
                Error('Invalid arguments: StartColumn must be lower or equal to EndColumn.');

            exit(TextLines.Get(StartLine).Substring(StartColumn, EndColumn - StartColumn));
        end;

        RangeBuilder.Append(TextLines.Get(StartLine).Substring(StartColumn));
        RangeBuilder.Append(TypeHelper.LFSeparator());

        for i := StartLine + 1 to EndLine - 1 do begin
            RangeBuilder.Append(TextLines.Get(i));
            RangeBuilder.Append(TypeHelper.LFSeparator());
        end;

        RangeBuilder.Append(TextLines.Get(EndLine).Substring(1, EndColumn - 1));
        RangeBuilder.Append(TypeHelper.LFSeparator());

        exit(RangeBuilder.ToText());
    end;
}