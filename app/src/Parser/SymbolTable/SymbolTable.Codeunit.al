codeunit 69099 "Symbol Table FS" // TODO scoping?
{
    var
        Symbol: Record "Symbol FS";

    procedure DefineLocal
    (
        Name: Text[120];
        Type: Enum "Type FS"
    )
    begin
        Define(
            Name,
            Type,
            Enum::"Scope FS"::Local
        );
    end;

    procedure DefineParameter
    (
        Name: Text[120];
        Type: Enum "Type FS"
    )
    begin
        Define(
            Name,
            Type,
            Enum::"Scope FS"::Parameter
        );
    end;

    local procedure Define
    (
        Name: Text[120];
        Type: Enum "Type FS";
        Scope: Enum "Scope FS"
    )
    begin
        if Symbol.Get(Name) then
            Error('Variable %1 already exists.', Name);

        Symbol.Init();
        Symbol.Name := Name;
        Symbol.Type := Type;
        Symbol.Scope := Scope;
        Symbol.Order := GetNextOrder();
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

    procedure NumbericSymbol(): Record "Symbol FS"
    var
        Numberic: Record "Symbol FS";
    begin
        Numberic.Type := Numberic.Type::Number;
        exit(Numberic);
    end;

    procedure TextSymbol(): Record "Symbol FS"
    var
        Text: Record "Symbol FS";
    begin
        Text.Type := Text.Type::Text;
        exit(Text);
    end;

    procedure SymbolFromType(Type: Enum "Type FS"): Record "Symbol FS"
    begin
        case Type of
            Type::Boolean:
                exit(BooleanSymbol());
            Type::Number:
                exit(NumbericSymbol());
            Type::Text:
                exit(TextSymbol());
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
}