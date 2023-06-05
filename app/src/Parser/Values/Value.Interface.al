interface "Value FS"
{
    procedure GetValue(): Variant;
    procedure SetValue(NewValue: Variant);

    procedure GetType(): Enum "Type FS"

    procedure Copy(): Interface "Value FS" // TODO also add clone?
    procedure Mutate(NewValue: Interface "Value FS") // TODO is mutate actually different from SetValue?

    procedure GetProperty(Name: Text[120]): Interface "Value FS"
    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS")

    procedure Format(): Text
    procedure Format(Length: Integer): Text
    procedure Format(Length: Integer; FormatNumber: Integer): Text
    procedure Format(Length: Integer; FormatString: Text): Text

    procedure Evaluate(Input: Text; Throw: Boolean): Boolean
    procedure Evaluate(Input: Text; FormatNumber: Integer; Throw: Boolean): Boolean

    procedure At(Self: Interface "Value FS"; Index: Interface "Value FS"): Interface "Value FS"
}