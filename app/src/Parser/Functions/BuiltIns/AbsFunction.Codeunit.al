codeunit 69200 "Abs Function FS" implements "Function FS"
{
    procedure GetName(): Text[120];
    begin
        exit('Abs');
    end;

    procedure GetReturnType(): Enum "Type FS"
    begin
        exit(Enum::"Type FS"::Number);
    end;

    procedure GetArity(): Integer
    begin
        exit(1);
    end;

    procedure GetParameters(var ParameterSymbol: Record "Symbol FS")
    begin
        ParameterSymbol.InsertNumber('Number', 1);
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    var
        NumericValue: Codeunit "Numeric Value FS";
        Node: Codeunit "Value Linked List Node FS";
        Value: Decimal;
    begin
        Node := ValueLinkedList.First();

        Value := Abs(Node.Value().GetValue());
        NumericValue.SetValue(Value);

        exit(NumericValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS");
    begin
        // TODO do not call this for built ins?
    end;
}