codeunit 69099 "Symbol Table FS" // TODO scoping?
{
    var
        Symbol: Record "Symbol FS";
        ReturnTypeSymbol: Record "Symbol FS";

    procedure DefineReturnType(NewReturnTypeSymbol: Record "Symbol FS")
    begin
        ReturnTypeSymbol := NewReturnTypeSymbol;

        if NewReturnTypeSymbol.Name <> '' then
            Define(
                NewReturnTypeSymbol.Name,
                NewReturnTypeSymbol.Type,
                NewReturnTypeSymbol.Subtype,
                Enum::"Scope FS"::Local,
                false
            );
    end;

    procedure GetReturnType(): Record "Symbol FS"
    begin
        exit(ReturnTypeSymbol);
    end;

    procedure DefineLocal(VariableSymbol: Record "Symbol FS")
    begin
        Define(
            VariableSymbol.Name,
            VariableSymbol.Type,
            VariableSymbol.Subtype,
            Enum::"Scope FS"::Local,
            false
        );
    end;

    procedure DefineParameter(ParameterSymbol: Record "Symbol FS"; Pointer: Boolean)
    begin
        Define(
            ParameterSymbol.Name,
            ParameterSymbol.Type,
            ParameterSymbol.Subtype,
            Enum::"Scope FS"::Parameter,
            Pointer
        );
    end;

    local procedure Define
    (
        Name: Text[120];
        Type: Enum "Type FS";
        Subtype: Text[120];
        Scope: Enum "Scope FS";
        Pointer: Boolean
    )
    begin
        if Symbol.Get(Name) then
            Error('Variable %1 already exists.', Name);

        Symbol.Init();
        Symbol.Name := Name;
        Symbol.Type := Type;
        Symbol.Subtype := Subtype; // TODO upgrade to validated symbol during analysis, interpreter then uses validated symbols?
        Symbol.Scope := Scope;
        Symbol.Order := GetNextOrder();
        Symbol."Pointer Parameter" := Pointer;
        Symbol.Insert();
    end;

    local procedure GetNextOrder(): Integer
    var
        OrderedSymbol: Record "Symbol FS";
    begin
        OrderedSymbol.Copy(Symbol, true);
        OrderedSymbol.SetCurrentKey(Order);
        if not OrderedSymbol.FindLast() then
            exit(1);
        exit(OrderedSymbol.Order + 1);
    end;

    procedure Lookup(Name: Text[120]): Record "Symbol FS"
    begin
        if not Symbol.Get(Name) then
            Error('Symbol %1 does not exist.', Name);
        exit(Symbol);
    end;

    procedure VoidSymbol(): Record "Symbol FS"
    var
        Void: Record "Symbol FS";
    begin
        Void.Type := Void.Type::Void;
        exit(Void);
    end;

    procedure BooleanSymbol(): Record "Symbol FS"
    var
        Boolean: Record "Symbol FS";
    begin
        Boolean.Type := Boolean.Type::Boolean;
        exit(Boolean);
    end;

    procedure NumericSymbol(): Record "Symbol FS"
    var
        Numeric: Record "Symbol FS";
    begin
        Numeric.Type := Numeric.Type::Number;
        exit(Numeric);
    end;

    procedure TextSymbol(): Record "Symbol FS"
    var
        Text: Record "Symbol FS";
    begin
        Text.Type := Text.Type::Text;
        exit(Text);
    end;

    procedure DateSymbol(): Record "Symbol FS"
    var
        Date: Record "Symbol FS";
    begin
        Date.Type := Date.Type::Date;
        exit(Date);
    end;

    procedure TimeSymbol(): Record "Symbol FS"
    var
        Time: Record "Symbol FS";
    begin
        Time.Type := Time.Type::Time;
        exit(Time);
    end;

    procedure DateTimeSymbol(): Record "Symbol FS"
    var
        DateTime: Record "Symbol FS";
    begin
        DateTime.Type := DateTime.Type::DateTime;
        exit(DateTime);
    end;

    procedure SymbolFromType(Type: Enum "Type FS"): Record "Symbol FS"
    begin
        case Type of
            Type::Boolean:
                exit(BooleanSymbol());
            Type::Number:
                exit(NumericSymbol());
            Type::Text:
                exit(TextSymbol());
            Type::Date:
                exit(DateSymbol());
            Type::Time:
                exit(TimeSymbol());
            Type::DateTime:
                exit(DateTimeSymbol());
            Type::Void:
                exit(VoidSymbol());
            else
                Error('Unsupported type %1.', Type);
        end;
    end;

    procedure FindSet(var OutSymbol: Record "Symbol FS"): Boolean
    begin
        Symbol.SetCurrentKey(Order);
        if not Symbol.FindSet() then
            exit(false);
        OutSymbol := Symbol;
        exit(true);
    end;

    procedure Next(var OutSymbol: Record "Symbol FS"): Boolean
    begin
        Symbol.SetCurrentKey(Order);
        if Symbol.Next() = 0 then
            exit(false);
        OutSymbol := Symbol;
        exit(true);
    end;

    procedure GetParameterCount(): Integer
    var
        ParameterSymbol: Record "Symbol FS";
    begin
        ParameterSymbol.Copy(Symbol, true);
        ParameterSymbol.SetRange(Scope, ParameterSymbol.Scope::Parameter);
        exit(ParameterSymbol.Count());
    end;

    procedure GetParameters(var ParameterSymbol: Record "Symbol FS")
    begin
        ParameterSymbol.Reset();
        ParameterSymbol.DeleteAll();

        Symbol.SetRange(Scope, ParameterSymbol.Scope::Parameter);
        if Symbol.FindSet() then
            repeat
                ParameterSymbol := Symbol;
                ParameterSymbol.Insert();
            until Symbol.Next() = 0;
        Symbol.SetRange(Scope);
    end;

    procedure Validate()
    begin
        ReturnTypeSymbol.ValidateType();

        if Symbol.FindSet() then
            repeat
                Symbol.ValidateType();
            until Symbol.Next() = 0;
    end;
}