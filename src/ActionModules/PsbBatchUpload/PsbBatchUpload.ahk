#Include "./PsbBatchUpload_Action.ahk"

PsbBatchUpload(App) {
    pbu := Component(App, A_ThisFunc)
    pbu.description := "旅业二期（网页版）批量上报"

    pbu.render := (this) => this.Add(
        App.AddGroupBox("Section w350 x30 y400 r4", "旅业二期（网页版）批量上报"),
        App.AddText("xs10 yp+30 h20 0x200", "使用请先打开 360 浏览器和旅业后台。"),
        App.AddReactiveButton("vPsbBatchUploadAction Default xs10 y+20 w100", "批量上报")
           .OnEvent("Click", (*) => PsbBatchUpload_Action.USE())
    )

    return pbu
}