// SSDT to correct some problems headphone/mic on CX20752.
//
// created by nayeweiyang/XuWang

DefinitionBlock ("", "SSDT", 1, "XuWang", "CX20752", 0)
{
    External(_SB.PCI0.HDEF, DeviceObj)
    
    Name(_SB.PCI0.HDEF.RMCF, Package()
    {
        "CodecCommander", Package()
        {
            "Custom Commands", Package()
            {
                Package(){}, // signifies Array instead of Dictionary
                Package()
                {
                    // 0x19 SET_PIN_WIDGET_CONTROL 0x24
                    "Command", Buffer() { 0x01, 0x97, 0x07, 0x24 },
                    "On Init", ">y",
                    "On Sleep", ">n",
                    "On Wake", ">y",
                },
                Package()
                {
                    // 0x1a SET_PIN_WIDGET_CONTROL 0x24
                    "Command", Buffer() { 0x01, 0xa7, 0x07, 0x24 },
                    "On Init", ">y",
                    "On Sleep", ">n",
                    "On Wake", ">y",
                },

            },
        },
    })
}

