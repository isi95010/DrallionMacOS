/*
This SSDT is to re-sync the display lid status so that the laptop 
consistently boots in an awake state rather than going 
straight to sleep at boot. 

Important: This relies on renaming the orignal _REG method 
to XREG in OpenCore's ACPI/Patch, like so: 

| Comment | String  | _REG to XREG |
| Count   | Number  | 0            |
| Enabled | Boolean | True         | 
| Find    | Data    | 5F524547     |
| Replace | Data    | 58524547     |

*/
DefinitionBlock ("", "SSDT", 2, "sqrl", "reglid", 0x00000000)
{
    External (_SB_.PCI0.LPCB.EC0, DeviceObj)
    External (_SB_.PCI0.LPCB.EC0.LID0, DeviceObj) // This is the Lid device that needs to be notified
    External (_SB_.PCI0.LPCB.EC0.XREG, MethodObj) // This is the original method that we need to append
    External (_SB_.LIDS, FieldUnitObj) // This reads the physical status of the lid.
        
    Scope (\_SB.PCI0.LPCB.EC0)
    {
        Method (_REG, 2, NotSerialized)  // Defines a new method called _REG
        {
            Debug = "New _REG called"
            \_SB.PCI0.LPCB.EC0.XREG (Arg0, Arg1) // First it calls XREG
            Notify (LID0, LIDS) // Then it updates the Lid on the current status.
        }
    }      
}