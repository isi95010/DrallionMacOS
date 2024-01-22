/*
This is for undiding the ME interface from MacOS to support 
proper wake up
*/
DefinitionBlock ("", "SSDT", 2, "sqrl", "bigssdt", 0x00001000)
{
    External (_SB_, DeviceObj)
    External (_SB_.PCI0, DeviceObj)
Scope (_SB.PCI0)
    {
        Device (IMEI)
        {
            Name (_ADR, 0x00160000)  // _ADR: Address
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
}