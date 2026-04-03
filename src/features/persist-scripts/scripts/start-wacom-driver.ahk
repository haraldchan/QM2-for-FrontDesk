StartWacomDriver(arg*) {
    btn := arg[1] is Gui.Button ? arg[1] : { Enabled: false } ; just placeholder
    btn.Enabled := false

    wacomService := "WTabletServicePro"

    shell := ComObject("WScript.Shell")
    output := shell.Exec("sc query " . wacomService).StdOut.ReadAll()

    switch {
        case InStr(output, "OpenService FAILED 1060"):
            MsgBox("Wacom 驱动未安装，请安装后重试。", POPUP_TITLE, "4096 icon!")
            btn.Enabled := true
            return
        case InStr(output, "RUNNING"):
            shell.Run(Format("sc stop {1}", wacomService), 0)
    }

    shell.Run(Format("sc start {1}", wacomService), 0)
    Sleep(1000)

    if (shell.Exec("sc query " . wacomService).StdOut.ReadAll().includes("RUNNING")) {
        MsgBox("Wacom 驱动已启动。", , "4096 T1 iconi")
    }
    else {
        MsgBox("Wacom 驱动启动失败，请查看是否正确安装。", POPUP_TITLE, "4096 T1 icon!")
    }

    btn.Enabled := true
    shell := ""
}