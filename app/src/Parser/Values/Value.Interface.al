interface "Value FS"
{
    procedure GetValue(): Variant;
    procedure SetValue(NewValue: Variant);

    procedure GetType(): Enum "Type FS"
}