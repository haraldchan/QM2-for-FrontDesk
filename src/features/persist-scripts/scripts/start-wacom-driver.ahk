StartWacomDriver(*) {
    wacomService := "WTabletServicePro"

    shell := ComObject("WScript.Shell")
    output := shell.Exec("sc query " . wacomService).StdOut.ReadAll()

    switch {
        case InStr(output, "OpenService FAILED 1060"):
            MsgBox("Wacom 驱动未安装，请安装后重试。", POPUP_TITLE, "4096 icon!")
            return
        case InStr(output, "RUNNING"):
            shell.Run(Format("sc stop {1}", wacomService), 0)
    }

    shell.Run(Format("sc start {1}", wacomService), 0)
    shell := ""
}