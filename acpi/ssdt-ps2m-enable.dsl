DefinitionBlock ("", "SSDT", 2, "sqrl", "ps2m", 0x00000001)
{
    External (_SB_.PCI0.PS2M, DeviceObj)
    Scope (\_SB.PCI0.PS2M)
    {
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If (_OSI ("Darwin"))
            {
                Return (0x0F)
            }
            Else
            {
                Return (Zero)
            }
        }
    }
}