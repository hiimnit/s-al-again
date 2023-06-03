codeunit 69213 "CalcDate Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('CalcDate');
    end;

    procedure GetReturnType(TopLevel: Boolean): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.DateSymbol());
    end;

    procedure ValidateCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Arguments: Codeunit "Node Linked List FS"
    )
    var
        ParameterSymbol, Symbol : Record "Symbol FS";
        ArgumentNode: Codeunit "Node Linked List Node FS";
    begin
        if not (Arguments.GetCount() in [1, 2]) then
            Error('Parameter count missmatch when calling method %1.', GetName());

        ArgumentNode := Arguments.First();

        Symbol := ArgumentNode.Value().ValidateSemantics(Runtime, SymbolTable);
        case Symbol.Type of
            Symbol.Type::DateFormula:
                ParameterSymbol.InsertDateFormula('DateFormula', 1);
            else
                ParameterSymbol.InsertText('Text', 1);
        end;
        Runtime.TestParameterVsArgument(
            Runtime,
            SymbolTable,
            GetName(),
            ParameterSymbol,
            ArgumentNode,
            Symbol
        );

        if Arguments.GetCount() = 1 then
            exit;

        ArgumentNode := ArgumentNode.Next();
        ParameterSymbol.InsertDate('Date', 2);
        Runtime.TestParameterVsArgument(
            Runtime,
            SymbolTable,
            GetName(),
            ParameterSymbol,
            ArgumentNode
        );
    end;

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS"
    var
        DateValue: Codeunit "Date Value FS";
        ValueNode: Codeunit "Value Linked List Node FS";
        DateFormula: DateFormula;
        Value, Date : Interface "Value FS";
        Text: Text;
        Result: Date;
    begin
        ValueNode := ValueLinkedList.First();
        Value := ValueNode.Value();

        if not ValueNode.HasNext() then begin
            case true of
                Value.GetValue().IsDateFormula:
                    begin
                        DateFormula := Value.GetValue();
                        Result := CalcDate(DateFormula);
                    end;
                else
                    Text := Value.GetValue();
                    Result := CalcDate(Text);
            end;

            DateValue.SetValue(Result);
            exit(DateValue);
        end;

        ValueNode := ValueNode.Next();
        Date := ValueNode.Value();

        case true of
            Value.GetValue().IsDateFormula:
                begin
                    DateFormula := Value.GetValue();
                    Result := CalcDate(DateFormula, Date.GetValue());
                end;
            else
                Text := Value.GetValue();
                Result := CalcDate(Text, Date.GetValue());
        end;

        DateValue.SetValue(CalcDate(Text, Date.GetValue()));
        exit(DateValue);
    end;
}