codeunit 69201 "Power Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('Power');
    end;

    procedure GetReturnType(): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.NumericSymbol());
    end;

    procedure GetArity(): Integer
    begin
        exit(2);
    end;

    // TODO this will make things difficult for functions with
    // >>>> variable parity - message, error, setrange...
    procedure GetParameters(var ParameterSymbol: Record "Symbol FS")
    begin
        ParameterSymbol.InsertNumber('Number', 1);
        ParameterSymbol.InsertNumber('Power', 2);
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    var
        NumericValue: Codeunit "Numeric Value FS";
        Node: Codeunit "Value Linked List Node FS";
        Number, Power, Result : Decimal;
    begin
        Node := ValueLinkedList.First();
        Number := Node.Value().GetValue();
        Node := Node.Next();
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