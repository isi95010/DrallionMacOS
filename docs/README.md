# DrallionMacOS (WIP)
## Tips for using MacOS on the Dell Latitude Chromebook 7410, referred to as Drallion. 
The 7410 came in various hardware configurations built to order. This guide was made using the following hardware configuration: 

- Intel i7 10610U Processor
- 16gb of soldered RAM
- 2-in-1 chassis, meaning it has a flip-touchscreen. 

Take note that the Windows PC version of the 7410 is _not_ the same despite having a near-identical physical appearance. 

This laptop is from 2020 and uses a Comet Lake CPU. This is the only Comet Lake Chromebook which has an HDA audio codec compatible with AppleALC. Setting up MacOS on Chromebooks, especially this one, is not as straightfoward with other "regular" Comet Lake laptops, so don't skip any section or warning herein. 

**A complete EFI is not provided in this repo, in accordance with "DIY" tradition. DIY: Do It Yourself. You will be better familiar with the process and will be able to troubleshoot on your own by starting with the [Dortania OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/coffee-lake-plus.html). Please do not request an EFI here.**

## Table of Contents
- [Current Status Table](#current-status)
- [Versions Tested](#versions-tested)
- [Requirements](#preferred-requirements)
- [Issues](#current-issues)
- [Installation](#installation)
   - [Required Steps](#these-steps-are-required-for-proper-functioning)
   - [Coreboot 4.20.0+ CPU patch](#working-around-cpu-changes-to-coreboot)
   - [Suggested Kexts](#kexts)
   - [Suggested ACPI files and hotpatches](#acpi-folder)
- [Misc. Information](#misc-information)

## Current Status

| **Feature**        | **Status**           | **Notes**                                                                                     |
|--------------------|----------------------|-----------------------------------------------------------------------------------------------|
| WiFi               | Working              | See [OpenIntelWireless](https://openintelwireless.github.io). Seems to work more reliably by Fixing DMAR.                            |
| Bluetooth          | Working              | See [OpenIntelWireless](https://openintelwireless.github.io)                                                                         |
| Sleep/Wake         | Working              | See section about Coreboot fork to fix apps crashing when waking from sleep.                   |
| Trackpad           | Working              | Works with newer commit of VoodooI2CElan. See section in [Input Devices](#input-devices).                       | 
| Graphics Accel.    | Working              |                                                                                               |
| Internal Speakers  | Working              | AppleALC.kext using layout-id 22 on Catalina+. Combo jack needs HDA Verb sent, IE `alc-verb 0x19 0x707 0x24`                            |
| Keyboard backlight | Not Working in MacOS |                                                                                               |
| Brightness keys | Working | Use 1revenger1's fork of VoodooPS2 and look at my SSDT. See section in [Input Devices](#input-devices). |
| Keyboard & Remaps  | Working              | Use 1revenger1's fork of VoodooPS2 and look at my SSDT. See section in [Input Devices](#input-devices).                                   |
| SD Card Reader     | Working              | It is a Realtek PCIE MicroSD card reader. It seems to work with [0xFirewolf's kext](https://github.com/0xFireWolf/RealtekCardReader).             |
| Headphone Jack     | WIP                  | Combo jack needs HDA Verb sent, IE `alc-verb 0x19 0x707 0x24`                                                             |
| HDMI Audio         | Working              |                                                                                               |
| HDMI Video         | Working              | Somewhat janky detecting displays but works in a roundabout way.                              |
| USB Ports          | Working              | Working with USB mapping                                                                      |
| Webcam             | Working              | Working with USB mapping                                                                      |
| Internal Mic.      | Working              | AppleALC.kext using layout-id 22 on Catalina+                                                             |
| Shutdown / Restart | Working              |                                                                                               |    
| Continuity         | Untested             | Browser handoff seems to work from iPhone. Haven't tested more features                                                       |    
| NVRAM              | Working              | Native NVRAM working with DevirtualiseMMIO set to False                                       |
                                                                          
--------------------------------------------------------------------------------------------------------------------------------------------------------
### Versions Tested

- 10.14.5 (Mojave) 
- 13 (Ventura) 
- 14 (Sonoma)

### Preferred Requirements

This document assumes you've already disabled write protect and successfuly flashed the [Chromeintosh fork](https://github.com/Chromeintosh/coreboot) of MrChromebox's  Coreboot firmware to your device. It does not cover flashing. Before you start, you'll need to have the following items to complete the process:

- A Core i variant of the Dell Latitude Chromebook 7410.  
- An external storage device (can range from a MicroSD card to a USB Disk / Drive) for creating the installer USB.  
- Small philips screwdriver and "spudger" for opening the laptop chassis. This is for unplugging the battery to enable developer mode (if you haven't flashed the firmware yet) and optionally to replace the stock SSD (need at least a 64GB m.2 NVME).
- Experience with MacOS
- Experience with hackintoshing with OpenCore is preferable because this is even more niche than installing MacOS on a PC.
- Knowledge about ACPI code and hotpatching
- A USB mouse and keyboard in case you have trouble with the built-in input devices. 

### Current Issues
- ~~The main issue with Drallion currently is that the machine randomly boots MacOS directly into sleep as it thinks the lid is closed. I am currently looking into a fix via SSDT, but this may not get resolved. To work around this, just close and open the lid late in the MacOS boot process, around where IG verbose begins to print.~~ Update: The fix is to add `Notify (\_SB.PCI0.LPCB.EC0.LID0, \LIDS)` to the _REG method. See [ssdt-reg-lid0](https://github.com/isi95010/DrallionMacOS/blob/main/acpi/ssdt-reg-lid0.dsl) for more.
- ~~The next priority issue would be 3.5mm combo jack. Unfortunately output produces static, so in the future hopefully I'll have time to create a new Layout ID and push it to the AppleALC repo.~~ Combo jack needs alcverbs=1 boot-arg and an HDA Verb sent, IE `alc-verb 0x19 0x707 0x24`. Internal speakers and mic work fine with layout-id 22, however.
- External video output is a bit janky currently. The HDMI port and both USB-C ports can output a signal (be sure to set the port type to HDMI on them all via DeviceProperties), but the USB-C port closest to the HDMI port shares the same framebuffer as the HDMI port. Oddly, you need to plug the video cable in twice per boot for a signal to output. ~~From there, the internal display will disable itself for some reason. You should be able to re-enable the internal display by closing and re-opening the lid.~~ Update: adding `Notify (\_SB.PCI0.LPCB.EC0.LID0, \LIDS)` to the _REG method also seems to eliminate the display turning off when an external screen is connected. 
- The last item that comes to mind is that the power button doesn't work correctly within MacOS. You can forcefully power off by long pressing power or short pressing left Ctrl+power, but no dialog pops up to select the action, like a real MacBook. Hopefully I can come up with a fix, WIP. 
 
>**Note**: MrChromebox coreboot 4.20 (5/15/2023 release) and higher is confirmed to cause issues with booting macOS on Chromebooks without taking specific steps. There are several methods to work around this, but the most simple recommendation is to build Coreboot with the mods in the [Chromeintosh Repo](https://github.com/Chromeintosh/coreboot). Don't forget to consult the Chrultrabook Docs site to preserve your VPD.

## Installation

# ***Warning:*** This is an advanced hobbyist project. There is no tech support and the authors of this document and authors of the documents linked are not responsible for damage to your device. Any claims about functionality may be opinion and are open to challenge. We will try to keep this guide up-to-date as new information emerges, but may become outdated at any point in the future. To discuss, feel free to post in the [Chrultrabook Forums](https://forum.chrultrabook.com/c/support/macos-support) or in the Hackintosh Paradise Discord server.

### These steps are ***required*** for proper functioning.

1. If you haven't already, flash MrChromebox Coreboot (ideally with the mods from Chromeintosh) onto your Chromebook after turning off hardware write protection using the [unplug battery method](https://docs.chrultrabook.com/docs/firmware/battery.html). The mods from Chromeintosh work in other OSes too, but building it this was has optimizations for MacOS. Again, they are still compatible with Windows and Linux.  
2. Thoroughly read the [OpenCore Guide](https://dortania.github.io/OpenCore-Install-Guide/). Use ["Laptop Coffe Lake Plus and Comet Lake"](https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/coffee-lake-plus.html) when ready to set up your EFI. Be sure to use the Debug version of OpenCore initially.
   * See [here](https://dortania.github.io/OpenCore-Install-Guide/troubleshooting/debug.html) for OpenCore debugging info
   * Enable the SysReport quirk in order to dump your ACPI tables, especially your DSDT to run through SSDTTime to generate ***required SSDT's*** as mentioned in step 9. 
3. Re-visit this guide when you're done setting up your EFI. There are a few things we need to tweak to ensure our Chromebook works with macOS. 
4. Fixing CPU core (thread) definition and plugin-type as mentioned in Current Issues
	* My recommended way: Build and flash the Chromeintosh fork of MrChromebox's Coreboot.
	* Use SSDT-Plug-Alt.aml
5. In your `config.plist`, under `Booter -> Quirks` set `ProtectMemoryRegions` to `TRUE` and (_THIS IS IMPORTANT_) `DevirtualiseMmio` to `FALSE`. Other than the defaults in the Dortania guide, it should look something like this in your `config.plist` when done correctly:

   | Quirk                | Type | Value    |
   | -------------------- | ---- | -------- |
   | ProtectMemoryRegions | Boolean | True  |
   | DevirtualiseMmio     | Boolean | False |
   
   DevirtualiseMmio being false is for native NVRAM, whish is required to get through installing MacOS.
   
   > **Warning:** The above quirks are super important to MacOS.

6. `DeviceProperties -> Add -> PciRoot(0x0)/Pci(0x2,0x0)` 

 **`disable-telemetry-load` seems to be required to boot MacOS. Don't forget it!**
 The following modifications are recommended to enable graphics acceleration, enable smooth LCD backlight stepping, correct the HDMI output signal type, etc: 
  
   | Key                                        | Type   | Value    |
   | -------------------------------------------| ----   | -------- |
   | AAPL,ig-platform-id                        | data   | 0900A53E |
   | device-id                                  | data   | 9B3E0000 |
   | framebuffer-patch-enable                   | data   | 01000000 |
   | framebuffer-con0-enable                    | data   | 01000000 |
   | framebuffer-con0-type                      | data   | 00020000 |
   | framebuffer-con1-enable                    | data   | 01000000 |
   | framebuffer-con1-type                      | data   | 00080000 |
   | framebuffer-con2-enable                    | data   | 01000000 |
   | framebuffer-con2-type                      | data   | 00080000 |
   | force-online                               | data   | 01000000 |
   | enable-dpcd-max-link-rate-fix              | data   | 01000000 |
   | hda-gfx                                    | string | onboard-1|
   | enable-backlight-registers-alternative-fix | data   | 01000000 | 
   | enable-backlight-smoother                  | data   | 01000000 |
   | disable-telemetry-load                     | data   | 01000000 |   
   | rps-control				| data	 | 01000000 | 
   | enable-hdmi20				| data	 | 01000000 |
     
   > **You are free to experiment with different `AAPL,ig-platform-id`'s but 0900A53E seems to work well**
7. **`MacBookPro15,4` works with Mojave 10.15.4 through Sonoma** with the proper SecureBootModel and APFS settings in your OpenCore config. Anything before or after those MacOS versions is not covered here. You may find a better suited SMBIOS to mimic or for unsupported future OS versions. Experiment as you wish. 
8. It's recommended to use [1revenger1's fork of VoodooPS2](https://github.com/1Revenger1/VoodooPS2) which allows for mapping keys with HID Usages. You can see my SSDT here, but you'll still probably want to customize within MacOS to your liking.
9. It's recommended to use SSDTTime to generate a fake EC (laptop verion), HPET (IRQ conflicts) and PNLF (requred for display backlight control). Be sure to copy any resulting rename patches from `oc_patches.plist` into your `config.plist` under `ACPI -> Patch`. 
10. Map your USB ports before installing using Windows. If you don't want to install Windows, mapping can be done in WinPE. See [USBToolbox](https://github.com/USBToolBox). Remember you need the USBToolbox.kext *and* your generated UTBMap.kext.    
11. Snapshot (cmd + r) or (ctrl + r) your `config.plist`. 

    > **Warning**: Don't use "clean snapshot" (`ctrl/cmd+shift+r`) in Propertree after initially copying the sample as config.plist. This can **wipe** some work. Only do *regular* snapshots after first starting. (`ctrl/cmd+r`)

12. Attempt to install the OS

> **Reminder**: In depth information about OpenCore can be found [here.](https://dortania.github.io/docs/latest/Configuration.html)

--------------------------------------------------------------------------------------------------------------------------------------------------------

### Working around CPU changes to Coreboot
Coreboot UEFI firmware 4.20 (5/15/2023 release) has a known issue where booting macOS will hang even if you think you've created a plugin-type SSDT. To fix this, build Coreboot for Drallion based on the Chromeintosh fork and the CPU address, among other things, is solved. Then you can use SSDTTime like the Dortania Guide suggests.
### Input devices 
- Keyboard
    - Use [1revenger1's fork of VoodooPS2](https://github.com/1Revenger1/VoodooPS2) 
    - Compile my key mapping SSDT, or map yourself by researching HID Usage Pages and HID Usages. 
- I2C Touchscreen (WCOM48E2)
    - Works with VoodooI2C and VoodooI2CHID. Use an updated VoodooGPIO which includes [commit692f9e4](https://github.com/VoodooI2C/VoodooGPIO/commit/692f9e4c6c01aee2d2953778126eea677e7b46d1). 
    - GPIO interrupt mode can be achieved using my SSDT or making your own (pin 0x117)
- ~~Touchpad in PS2 emulation mode~~

>~~Sadly, the Elan touchpad does not work in I2C mode in MacOS and this may never change. Luckily, the hardware supports emulating the touchpad as a PS2 mouse (with VoodooPS2Mouse.kext). Only one ACPI rename patch is required to enable PS2 emulation, and another rename + SSDT hotpatch to "enable" the PS2M device in ACPI. PS2 mode limits the touchpad to single finger input and click/tap. IE, no scrolling using 2 fingers or right-clicking with two-finger taps. You can right click by clicking or tapping on the bottom right side. Having such limited gestures in PS2 mode is not too bad if you have a Drallion with a compatible touchscreen, like the WCOM48E2. You can use multi-finger gestures with the touchscreen. Fortunately, the touchpad will still work in I2C mode in Windows and Linux because PS2 emulation mode in MacOS is achieved with hotpaching using OpenCore. Keep in mind that if you use other OSes, you may need to fully shutdown before restarting in MacOS (IE, cold boot) to reactivate PS2 mode.~~

- Elan Touchpad in I2C mode
	- Works with VoodooI2C release + VoodooI2CElan with the commit [#42d8f31](https://github.com/VoodooI2C/VoodooI2CELAN/commit/42d8f31aa964be557efbfbc9f8ffca4f436558a4). Credit to 1revenger1 for identifying the problem.
	  - Until the VoodooI2C org releases the next version with the commit applied, you must build the kext yourself. Setting up the [build environment for VoodooI2C](https://voodooi2c.github.io/#Build%20Environment/Build%20Environment) seems a lot easier in Catalina, but the actual [fix]((https://github.com/VoodooI2C/VoodooI2CELAN/commit/42d8f31aa964be557efbfbc9f8ffca4f436558a4)) is easy to apply and then build the kext with.
	- GPIO interrupt mode can be achieved using my SSDT or making your own (pin 0x23)

### Kexts

Propertree *should* arrange the kexts in the correct order when using OC Snapshot, but here are the enabled kexts and how I've ordered them in my config.plist when using MacOS Sonoma: 

```
Lilu.kext
VirtualSMC.kext
SMCBatteryManager.kext
SMCSuperIO.kext
SMCProcessor.kext
SMCLightSensor.kext
ECEnabler.kext
AppleALC.kext
WhateverGreen.kext
AirtportItlwm.kext (use the [alpha](https://github.com/OpenIntelWireless/itlwm/releases/tag/v2.3.0-alpha), and be aware there are different kexts for different MacOS versions)
USBToolbox.kext
UTBMap.kext - create this by mapping usb ports
IntelBluetoothFirmware.kext
IntelBTPatcher.kext
BlueToolFixup.kext
VoodooInput.kext (from https://github.com/acidanthera/VoodooInput) 
VoodooGPIO.kext (built using commit commit692f9e4)
VoodooI2CServices.kext
VoodooI2C.kext
VoodooI2CHID.kext
VoodooI2CElan.kext (built using commit 42d8f31)
VoodooPS2Controller.kext (from https://github.com/1Revenger1/VoodooPS2)
VoodooPS2Keyboard.kext
VoodooPS2Mouse.kext
DebugEnhancer.kext (not required unless you're debugging constantly like me)
RealtekCardReader.kext
RealtekCardReaderFriend.kext
```
***Any kexts that are auto-loaded when performing an OC Snapshot but not listed above should be disabled in your config.plist.***

--------------------------------------------------------------------------------------------------------------------------------------------------------

### ACPI Folder

| File | Description | Rename(s) or drop needed? |
| -------------------- | ---- | -------- |
| DMAR.aml | Removes Reserved Regions from DMAR | Yes, drop DMAR |
| [ssdt-reg-lid0.aml](https://github.com/isi95010/DrallionMacOS/blob/main/acpi/ssdt-reg-lid0.dsl) | Lid status "sync" to ensure laptop doesn't sleep immediately after booting | Yes, _REG to XREG |
| [SSDT-EC-USBX.aml "laptop version"](https://github.com/isi95010/DrallionMacOS/blob/main/acpi/ssdt-ec-usbx.dsl) | Fake EC and USB power properties | No |
| [SSDT-ALS0.aml](https://github.com/isi95010/DrallionMacOS/blob/main/acpi/ssdt-als0.dsl) | Fake Ambient Light sensor for display brightness | No |
| [SSDT-IMEI.aml](https://github.com/isi95010/DrallionMacOS/blob/main/acpi/ssdt-imei.dsl) | ACPI device for IMEI - needed for ME interface to fix wake crashes | No | 
| [SSDT-PNLF.aml](https://github.com/isi95010/DrallionMacOS/blob/main/acpi/ssdt-pnlf.dsl) | Display brightness | No |
| SSDT-HPET.aml | HPET IRQ fixes from SSDTTime | YES, SSDTTime will output the renames for you to copy |
| [SSDT-Plug.aml](https://github.com/isi95010/DrallionMacOS/blob/main/acpi/SSDT-PLUG.dsl) | CPU thread def and plugin-type for power management | No |
| ~~[ssdt-ps2m-enable.aml](https://github.com/isi95010/DrallionMacOS/blob/main/acpi/ssdt-ps2m-enable.dsl)~~ | ~~Sets emulated PS2 mouse on~~ | ~~Yes, `_STA to XSTA` in base `\_SB_.PCI0.PS2M`~~ | 
| [drallion-keymap.aml](https://github.com/isi95010/DrallionMacOS/blob/main/acpi/drallion-keymap.dsl) | For keyboard keys like display brightness | No |
| [SSDT-screen.aml](https://github.com/isi95010/DrallionMacOS/blob/main/acpi/SSDT-screen.dsl) | For GPIO pinning the touchscreen | Yes, `_CRS to XCRS` in base `\_SB_.PCI0.I2C0.H00A` | 
| [SSDT-I2C-elan23.aml](https://github.com/isi95010/DrallionMacOS/blob/main/acpi/SSDT-I2C-elan23.dsl) | For GPIO pinning the touchpad | Yes, `_CRS to XCRS` in base `\_SB_.PCI0.I2C0.D015` | 


**Note**: Some of these SSDTs were generated with [SSDTTime](https://github.com/corpnewt/SSDTTime) and some were manually written by me for *this specific* Chromebook. See the [ACPI Sample folder](https://github.com/isi95010/DrallionMacOS/tree/main/acpi) for .dsl files you can download, double check, then compile into AML. From there, add them to your OpenCore ACPI folder, and Snapshot your config.plist. See the next section for critical rename hotpatches. 

#### ACPI Rename Patches

In addition to the renames produced by SSDTTime, here are required renames and descriptions. 

Take note that some renames require a Base value. 

| ~~Key~~                  | ~~Type~~   | ~~Value~~              |
| -------------------- | ------ | ------------------ |
| ~~Base~~                 | ~~String~~ |                    |
| ~~BaseSkip~~             | ~~Number~~ |    ~~0~~               |
| ~~Comment~~              | ~~String~~ | ~~(PS2M, Zero) to (PS2M One) for PS2 Trackpad~~ |
| ~~Count~~                | ~~Number~~ |    ~~2~~               |
| ~~Enabled~~              | ~~Boolean~~ |   ~~True~~             |
| ~~Find~~                 | ~~Data~~   | ~~575F5F5F 5053324D 00A01093~~ |
| ~~Limit~~                | ~~Number~~ |    ~~0~~               |
| ~~Mask~~                 | ~~Data~~   |      ~~<empty>~~       |
| ~~OemTableID~~           | ~~Data~~   |    ~~00000000~~        |
| ~~Replace~~              | ~~Data~~   | ~~575F5F5F 5053324D 01A01093~~ |
| ~~ReplaceMask~~          | ~~Data~~   |      ~~<empty>~~       |
| ~~Skip~~                 | ~~Number~~ |    ~~0~~               |
| ~~TableLength~~          | ~~Number~~ |    ~~0~~               |
| ~~TableSignature~~       | ~~Data~~   |    ~~00000000~~        |

| Key                  | Type   | Value              |
| -------------------- | ------ | ------------------ |
| Base                 | String |                    |
| BaseSkip             | Number |    0               |
| Comment              | String |_REG to XREG - for ssdt-reg-lid0|
| Count                | Number |    0               |
| Enabled              | Boolean|   True             |
| Find                 | Data   | 5F524547 |
| Limit                | Number |    0               |
| Mask                 | Data   |      <empty>       |
| OemTableID           | Data   |    00000000        |
| Replace              | Data   | 58524547 |
| ReplaceMask          | Data   |      <empty>       |
| Skip                 | Number |    0               |
| TableLength          | Number |    0               |
| TableSignature       | Data   |    00000000        |
	
	
| ~~Key~~                  | ~~Type~~   | ~~Value~~              |
| -------------------- | ------ | ------------------ |
| ~~Base~~                 | ~~String~~ |                    |
| ~~BaseSkip~~             | ~~Number~~ |   ~~0~~               |
| ~~Comment~~              | ~~String~~ | ~~_STA method to XSTA PS2M for ssdt-ps2m-enable~~ |
| ~~Count~~                | ~~Number~~ |    ~~1~~               |
| ~~Enabled~~              | ~~Boolean~~ |  ~~True~~             |
| ~~Find~~                 | ~~Data~~   | ~~0014085F 535441~~ |
| ~~Limit~~                | ~~Number~~ |    ~~0~~               |
| ~~Mask~~                 | ~~Data~~   |      ~~<empty>~~       |
| ~~OemTableID~~           | ~~Data~~   |    ~~00000000~~        |
| ~~Replace~~              | ~~Data~~   | ~~00140858 535441~~ |
| ~~vvvReplaceMask~~          | ~~Data~~   |      ~~<empty>~~       |
| ~~Skip~~                 | ~~Number~~ |    ~~0~~               |
| ~~TableLength~~          | ~~Number~~ |    ~~0~~               |
| ~~TableSignature~~       | ~~Data~~   |    ~~00000000~~        |

| Key                  | Type   | Value              |
| -------------------- | ------ | ------------------ |
| Base                 | String | `\_SB.PCI0.I2C0.H00A` |
| BaseSkip             | Number |    0               |
| Comment              | String |_CRS to XCRS in H00A for GPIO pinning of touchscreen|
| Count                | Number |    1               |
| Enabled              | Boolean|   True             |
| Find                 | Data   | 5F435253 |
| Limit                | Number |    0               |
| Mask                 | Data   |      <empty>       |
| OemTableID           | Data   |    00000000        |
| Replace              | Data   | 58435253 |
| ReplaceMask          | Data   |      <empty>       |
| Skip                 | Number |    0               |
| TableLength          | Number |    0               |
| TableSignature       | Data   |    00000000        |

| Key                  | Type   | Value              |
| -------------------- | ------ | ------------------ |
| Base                 | String | `\_SB.PCI0.I2C0.D015` |
| BaseSkip             | Number |    0               |
| Comment              | String |_CRS to XCRS in H00A for GPIO pinning of touchpad|
| Count                | Number |    1               |
| Enabled              | Boolean|   True             |
| Find                 | Data   | 5F435253 |
| Limit                | Number |    0               |
| Mask                 | Data   |      <empty>       |
| OemTableID           | Data   |    00000000        |
| Replace              | Data   | 58435253 |
| ReplaceMask          | Data   |      <empty>       |
| Skip                 | Number |    0               |
| TableLength          | Number |    0               |
| TableSignature       | Data   |    00000000        |

***Don't forget to add any renames generated by SSDTTime, namely for HPET SSDT.***

--------------------------------------------------------------------------------------------------------------------------------------------------------

## Misc. Information

- When formatting the SSD in Disk Utility, make sure to toggle "Show all Devices" from the View menu to start partitioning.
- Format the drive as `APFS` and `GUID Partition Table / GPT`
- Map your USB ports prior to installing macOS. You can use [USBToolBox](https://github.com/USBToolBox/tool) to do that. You'll need a second kext that goes along with it, [USBToolBox.kext](https://github.com/USBToolBox/kext). Your UTBMap.kext will not work without USBToolBox.kext. 
- AppleTV and other DRM protected services may not work.
- Optional: if you'd like to try using Hibernation, [HibernationFixup.kext](https://github.com/acidanthera/HibernationFixup) can help.
  - Set MacOS Hibernate mode to 3 using `pmset`(IE `sudo pmset standby 3').
  - HibernationFixup.kext needs to be given a boot-arg with bits set. I simply use `hbfx-ahbm=1`
  - In `pmset`, specify standby times based at the default 50% battery threshold. Personally, I've set `standbydelayhigh` at 3600 seconds and `standbydelaylow` at 1800 seconds.
    - This means that the laptop will hibernate after 30 minutes if the battery is less than 50%, but will hibernate after one hour if the battery has more than 50% remaining.
  - You can fine tune hibernation further, but I won't cover that. I will say hibernation helps massively with battery drain, since regular sleep does drain the battery quite a bit on this laptop. 

### Credits

* Credit to [mine-man30000](https://github.com/mine-man3000/macOS-Dragonair) for the guide this is based on.
* Credit to [meghan06](https://github.com/meghan06/) for the guide that mine-man3000's is based on, and for starting the Chromeintosh Org.
* Credit to all those who contribute to the [Chrultrabook project](https://docs.chrultrabook.com).
* Credit to [MrChromebox](https://github.com/MrChromebox?tab=repositories) for inadvertently making the firmware compatible with MacOS. 
* Credit to ExtremeXT for forking and including the modifications for a MacOS-friendly Coreboot.
* Credit to Ethan (ethanthesleepyone) for hosting builds and the MacOS firmware script originally. It's been taken down for the time being. 
* Credit to 1revenger1 for creating a new VoodooPS2 for Keyboard HID mapping, fixing VoodooI2CElan, and loads of guidance. 
* Credit to Coolstar for tuning Coreboot initially for Drallion. 
