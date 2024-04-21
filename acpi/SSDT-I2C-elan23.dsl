DefinitionBlock ("", "SSDT", 2, "sqrl", "ETPApin", 0x00000001)
{
    External (_SB_.PCI0.I2C1, DeviceObj)
    External (_SB_.PCI0.I2C1.D015, DeviceObj)

    Scope (\_SB.PCI0.I2C1.D015)
    {
        Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
        {
            If (_OSI ("Darwin"))
            {
                Local0 = ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0015, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PCI0.I2C1",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        GpioInt (Level, ActiveLow, ExclusiveAndWake, PullDefault, 0x0000,
                            "\\_SB.PCI0.GPIO", 0x00, ResourceConsumer, ,
                            )
                            {   // Pin list
                                0x0023
                            }
                    }
                Return (Local0)
            }
            Else
            {
                Local0 = ResourceTemplate ()
                    {
                        I2cSerialBusV2 (0x0015, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.PCI0.I2C1",
                            0x00, ResourceConsumer, , Exclusive,
                            )
                        Interrupt (ResourceConsumer, Level, ActiveLow, Shared, ,, )
                        {
                            0x00000033,
                        }
                    }
                Return (Local0)
            }
        }
    }
}