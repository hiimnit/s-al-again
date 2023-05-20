codeunit 69301 "Text ToLower FS" implements "Method FS"
{
    SingleInstance = true;

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        ValueLinkedList: Codeunit "Value Linked List FS"
    ): Interface "Value FS"
    var
        TextValue: Codeunit "Text Value FS";
        Text: Text;
    begin
        Text := Self.GetValue();
        TextValue.SetValue(Text.ToLower());
        exit(TextValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('ToLower');
    end;

    procedure GetInputType(): Enum "Type FS";
    begin
        exit(Enum::"Type FS"::Text);
    end;

    procedure GetReturnType(): Enum "Type FS";
    begin
        exit(Enum::"Type FS"::Text);
    end;

    procedure GetArity(): Integer;
    begin
        exit(0);
    end;

    procedure GetParameters(var ParameterSymbol: Record "Symbol FS");
    begin
    end;
}