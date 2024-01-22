/*
 * Drallion I2C Touchscreen
 * - GPIO Interrupts
 * - Makes sure Power Resources _ON and _OFF are called
 *
 * macOS does not utilize ACPI power resources, so these
 * need to be called manually in _PS0 and _PS3.
 *
 * Relies on _CRS being renamed to XCRS
 *  Base: \_SB.PCI0.I2C1.H010
 *  Count: 1
 *  Find: _CRS
 *  Replace: XCRS
 *  Enabled: True
 */
DefinitionBlock ("", "SSDT", 1, "sqrl", "screen", 0x00000001)
{
    External (_SB_.PCI0.I2C0.H00A, DeviceObj)
    External (_SB_.PCI0.I2C0.H00A.PR00._OFF, MethodObj)
    External (_SB_.PCI0.I2C0.H00A.PR00._ON_, MethodObj)

    Scope (\_SB.PCI0.I2C0.H00A)
    {

        //
        // Use GPIO as interrupt source
        // 

        Method (_CRS, 0, NotSerialized)
        {
            Local0 = ResourceTemplate ()
                {
                    I2cSerialBusV2 (
                        0x000A,
                        ControllerInitiated,
                        0x00061A80,
                        AddressingMode7Bit,
                        "\\_SB.PCI0.I2C0",
                        0x00,
                        ResourceConsumer,
                        ,
                        Exclusive,
                    )
                    GpioInt (
                        Level,
                        ActiveLow,
                        ExclusiveAndWake,
                        PullDefault,
                        0x0000,
                        "\\_SB.PCI0.GPIO",
                        0x00,
                        ResourceConsumer,
                        ,
                    ) 
                    {
                        0x117 // GPIO pin
                    } 
                }
            
            Return (Local0)
        }

        //
        // Replace Power Resources with _PSx calls
        //

        Method (_PS0, 0, NotSerialized)
        {
            ^PR00._ON ()
        }

        Method (_PS3, 0, NotSerialized)
        {
            ^PR00._OFF ()
        }
    }
}

