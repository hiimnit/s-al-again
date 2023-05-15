codeunit 69201 "Power Function FS" implements "Function FS"
{
    procedure GetName(): Text[120];
    begin
        exit('Power');
    end;

    procedure GetReturnType(): Enum "Type FS"
    begin
        exit(Enum::"Type FS"::Number);
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    var
        NumericValue: Codeunit "Numeric Value FS";
        Node: Codeunit "Value Linked List Node FS";
        Number, Power, Result : Decimal;
    begin
        ValueLinkedList.First(Node); // TODO what if it does not exist?
        Number := Node.Value().GetValue();
        Node.Next(Node); // TODO what if it does not exist?
        Power := Node.Value().GetValue();

        Result := Power(Number, Power);
        NumericValue.SetValue(Result);

        exit(NumericValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS");
    begin
        // TODO do not call this for built ins?
    end;
}