#Include "./InOutHelper_Action.ahk"

InOutHelper(App) {
    c := Component(App, A_ThisFunc)

    prevConf := signal("")
    nextConf := signal("")
    traceTemplate := "续住 Booking#{1}，In Out 即可"
    trace := computed(nextConf, next => !next ? "" : Format(traceTemplate, next))

    handleTraceTemplateUpdate(ctrl, _) {
        traceTemplate := ctrl.Text.replace(nextConf.value, "{1}")
    }

    action(*) {
        ; msgbox JSON.stringify(c.submit())

        WinActivate "ahk_class SunAwtFrame"
        InOutHelper_Action.handlePrevBooking()
    }

    c.render := this => this.Add(
        App.AddGroupBox("Section x30 y+10 w350 r10", ""),

        ; prev conf num
        App.AddText("xs10 yp+20 w50 h25 0x200", "旧确认号"),
        App.AREdit("vprevConf x+10 h25 w250", "{1}", prevConf).OnEvent("LoseFocus", (ctrl, _) => prevConf.set(ctrl.Value)),

        ; next conf num
        App.AddText("xs10 y+10 w50 h25 0x200", "新确认号"),
        App.AREdit("vnextConf x+10 h25 w250", "{1}", nextConf).OnEvent("LoseFocus", (ctrl, _) => nextConf.set(ctrl.Value)),
        
        ; trace template
        App.AddText("xs10 y+10 w50 h25 0x200", " Trace"),
        App.AREdit("vTraceText x+10 h75 w250", "{1}", trace).OnEvent("LoseFocus", handleTraceTemplateUpdate),


        ; exe btn
        App.AddButton("xs10 y+50", "go test").OnEvent("Click", action)
    )

    return c.render()
}