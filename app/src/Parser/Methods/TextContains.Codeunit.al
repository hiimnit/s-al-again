codeunit 69302 "Text Contains FS" implements "Method FS"
{
    SingleInstance = true;

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        ValueLinkedList: Codeunit "Value Linked List FS"
    ): Interface "Value FS"
    var
        BooleanValue: Codeunit "Boolean Value FS";
        Node: Codeunit "Value Linked List Node FS";
        Text, Subtext : Text;
    begin
        Text := Self.GetValue();
        Node := ValueLinkedList.First();
        Subtext := Node.Value().GetValue();

        BooleanValue.SetValue(Text.Contains(Subtext));
        exit(BooleanValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('Contains');
    end;

    procedure GetInputType(): Enum "Type FS";
    begin
        exit(Enum::"Type FS"::Text);
    end;

    procedure GetReturnType(): Enum "Type FS";
    begin
        exit(Enum::"Type FS"::Boolean);
    end;

    procedure GetArity(): Integer;
    begin
        exit(1);
    end;

    procedure GetParameters(var ParameterSymbol: Record "Symbol FS");
    begin
        ParameterSymbol.InsertText('Text', 1);
    end;
}