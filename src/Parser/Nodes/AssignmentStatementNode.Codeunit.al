codeunit 69018 "Assignment Statement Node FS" implements "Node FS"
{
    var
        Expression: Interface "Node FS";
        Name: Text;
        Operator: Enum "Operator FS";

    procedure Init
    (
        NewName: Text;
        NewExpression: Interface "Node FS";
        NewOperator: Enum "Operator FS"
    )
    begin
        Name := NewName;
        Expression := NewExpression;
        Operator := NewOperator; // TODO check on assignment?
    end;

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        PreviousValue, NewValue : Interface "Value FS";
        BinaryOperator: Enum "Operator FS";
    begin
        case Operator of
            Operator::"+=":
                BinaryOperator := BinaryOperator::"+";
            Operator::"-=":
                BinaryOperator := BinaryOperator::"-";
            Operator::"*=":
                BinaryOperator := BinaryOperator::"*";
            Operator::"/=":
                BinaryOperator := BinaryOperator::"/";
            Operator::":=":
                BinaryOperator := BinaryOperator::" ";
            else
                Error('Unimplemented assignment operator %1.', Operator);
        end;

        NewValue := Expression.Evaluate(Memory);

        if BinaryOperator <> BinaryOperator::" " then begin
            PreviousValue := Memory.Get(Name);

            // TODO multiplying strings is going to cause issues
            // >>>> currently it changes the datatype of the variable
            // >>>> should only be allowed one way
            NewValue := BinaryOperatorNode.Evaluate(
                PreviousValue.GetValue(),
                NewValue.GetValue(),
                BinaryOperator
            );
        end;

        Memory.Set(
            Name,
            NewValue
        );

        exit(VoidValue);
    end;
}