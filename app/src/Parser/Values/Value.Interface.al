interface "Value FS"
{
    procedure GetValue(): Variant;
    procedure SetValue(NewValue: Variant);

    procedure GetType(): Enum "Type FS"

    procedure Copy(): Interface "Value FS"

    procedure GetProperty(Name: Text[120]): Interface "Value FS"
    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS")
}