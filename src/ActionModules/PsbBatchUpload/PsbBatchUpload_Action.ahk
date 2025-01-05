class PsbBatchUpload_Action {
    static USE() {
        if (!WinExist("ahk_class 360se6_Frame")) {
            MsgBox("请先打开 360 浏览器/ 旅业二期！", "批量上报", "4096 T2")
            return
        }

        this.execute()
    }

    static execute() {
        js := Format(FileRead(A_ScriptDir . "\src\ActionModules\PsbBatchUpload\batch-upload-snippets.js", "UTF-8"))

        WinActivate("ahk_class 360se6_Frame")
        Send "^+j"
        Sleep 1000

        Send "允许粘贴"
        Send "{Enter}"
        Sleep 1000

        A_Clipboard := js
        Send "^v"
        Sleep 1000
        Send "{Enter}"
    }
}