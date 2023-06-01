codeunit 69323 "Record SetFilter FS" implements "Method FS"
{
    var
        FilterFieldName: Text[120]; // TODO store field id instead?

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        Arguments: Codeunit "Node Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS";
    var
        ArgumentNode: Codeunit "Node Linked List Node FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        ValueNode: Codeunit "Value Linked List Node FS";
        VoidValue: Codeunit "Void Value FS";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FieldId: Integer;
    begin
        RecordRef := Self.GetValue();
        FieldId := FindFieldId(RecordRef.Number(), FilterFieldName);
        FieldRef := RecordRef.Field(FieldId);

        ArgumentNode := Arguments.First().Next(); // skip first parameter
        ValueLinkedList := Runtime.EvaluateArguments(Runtime, ArgumentNode);
        ValueNode := ValueLinkedList.First();
        SetFilter(
            FieldRef,
            ValueNode.Value().GetValue(),
            ValueNode,
            ValueLinkedList.GetCount() - 1
        );

        exit(VoidValue);
    end;

    local procedure FindFieldId
    (
        TableId: Integer;
        Name: Text[120]
    ): Integer
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableId);
        Field.SetRange(FieldName, Name);
        Field.FindFirst();
        exit(Field."No.");
    end;

    // SetFilter behaves differently from StrSubstNo
    local procedure SetFilter
    (
        FieldRef: FieldRef;
        Template: Text;
        Node: Codeunit "Value Linked List Node FS";
        Length: Integer
    )
    begin
        case Length of
            0:
                FieldRef.SetFilter(Template);
            1:
                FieldRef.SetFilter(Template, NextNodeValue(Node));
            2:
                FieldRef.SetFilter(Template, NextNodeValue(Node), NextNodeValue(Node));
            3:
                FieldRef.SetFilter(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node));
            4:
                FieldRef.SetFilter(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node));
            5:
                FieldRef.SetFilter(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node));
            6:
                FieldRef.SetFilter(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node));
            7:
                FieldRef.SetFilter(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node));
            8:
                FieldRef.SetFilter(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node));
            9:
                FieldRef.SetFilter(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node));
            10:
                FieldRef.SetFilter(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node));
            else
                Error('Unimplemented: Too many arguments for text substitution.');
        end;
    end;

    local procedure NextNodeValue(var Node: Codeunit "Value Linked List Node FS"): Variant
    begin
        Node := Node.Next();
        exit(Node.Value().GetValue());
    end;

    local procedure MaxAllowedSubstitutions(): Integer
    begin
        exit(10);
    end;

    procedure GetName(): Text[120];
    begin
        exit('SetFilter');
    end;

    procedure GetReturnType(TopLevel: Boolean): Enum "Type FS";
    begin
        // XXX return self? chaining setrange?
        exit(Enum::"Type FS"::Void);
    end;

    procedure ValidateCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Self: Record "Symbol FS";
        Arguments: Codeunit "Node Linked List FS"
    )
    var
        Symbol, ParameterSymbol : Record "Symbol FS";
        ArgumentNode: Codeunit "Node Linked List Node FS";
    begin
        if not (Arguments.GetCount() in [2 .. MaxAllowedSubstitutions() + 2]) then
            Error('Parameter count missmatch when calling method %1.', GetName());

        ArgumentNode := Arguments.First();
        ParameterSymbol := ArgumentNode.Value().ValidateSemanticsWithContext(Runtime, SymbolTable, Self);
        if not ParameterSymbol.Property then
            Error('Expected the first argument to be a property.');

        FilterFieldName := ParameterSymbol.Name; // TODO bit of a hack

        ParameterSymbol.InsertText('Filter', 1);
        ArgumentNode := ArgumentNode.Next();
        Symbol := ArgumentNode.Value().ValidateSemantics(Runtime, SymbolTable);
        if not Runtime.MatchTypesAnyOrCoercible(ParameterSymbol, Symbol) then
            Error(
                'Parameter call missmatch when calling method %1.\\Expected %2, got %3.',
                GetName(),
                ParameterSymbol.TypeToText(),
                Symbol.TypeToText()
            );

        // all other arguments can be anything
        ParameterSymbol.InsertAny('Any', 1);
        while ArgumentNode.Next(ArgumentNode) do begin
            Symbol := ArgumentNode.Value().ValidateSemantics(Runtime, SymbolTable);
            if not Runtime.MatchTypesAnyOrCoercible(ParameterSymbol, Symbol) then
                Error(
                    'Parameter call missmatch when calling method %1.\\Expected %2, got %3.',
                    GetName(),
                    ParameterSymbol.TypeToText(),
                    Symbol.TypeToText()
                );
        end;
    end;
}