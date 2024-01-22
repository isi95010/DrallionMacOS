DefinitionBlock ("", "SSDT", 2, "sqrl", "drlmap", 0x00000000)
{
    External (_SB_.PCI0.PS2K, DeviceObj)

    Scope (\_SB.PCI0.PS2K)
    {
        Name (RMCF, Package (0x02)
        {
            "Keyboard", 
            Package (0x04)
            {
                "Swap command and option", 
                ">n", 
                "Custom ADB Map", 
                Package (0x0a)
                {
                    Package (0x00){}, 
                    "e06a=000c00b6", // Previous Track
                    "e067=000c00b0", // Play/Pause
                    "e055=000c00b5", // Skip Track
                    "e05b=000700e2", // ChrOS search = left alt (caps lock position)
                    "e015=00ff0005", // Brightness Down
                    "e011=00ff0004", // Brightness Up
                    "3f=00ff0009", // KB Brightness Down (hold fn + brightness) - placeholder, not working in MacOS
                    "40=00ff0008", // KB Brightness Up (hold fn + brightness) - placeholder, not working
                    "e054=00070039", // Globe key = caps
                }
            }
        })
    }
}