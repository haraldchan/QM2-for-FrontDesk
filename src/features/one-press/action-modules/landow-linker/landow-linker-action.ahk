#Include landow-macros.ahk

class LandowLinker_Action {
    /**
     * 
     * @param {String} orderType 
     * @param {Integer} [qty=1] 
     * @param {String} [remark] 
     */
    static sendServiceOrder(orderType, qty := 1, remark := "") {
        if (!WinExist("ahk_class SunAwtFrame")) {
            MsgBox("Opera PMS 未启动", POPUP_TITLE, "4096 T1 iconx")
            return
        }

        WinActivate("ahk_class SunAwtFrame")
        Sleep(200)

        found := PmsImageFinder.find("opera-active-win.png")
        if (!found) {
            return
        }

        CoordMode("Mouse", "Screen")
        A_Clipboard := ""
        MouseClickDrag("Left", found.outX + 120, found.outY + 302, found.outX, found.outY + 302)
        Sleep(200)
        Send("^c")
        if (!ClipWait(2)) {
            MsgBox("复制房号失败，请在预订界面中重试", POPUP_TITLE, "4096 T2 iconx")
            return
        }
        curRoomNum := A_Clipboard
        Sleep(200)

        Landow.createOrder(curRoomNum, orderType, qty, remark)
    }

    static roomStatusKeyMap := Map(
        "Dirty", "!d",
        "Inspected", "!i"
    )
    /**
     * 
     * @param {String} newRoomNum 
     * @param {String} reason 
     * @param {"Dirty" | "Inspected"} prevRoomStatus 
     */
    static sendRoomMove(newRoomNum, reason, prevRoomStatus) {
        if (!WinExist("ahk_class SunAwtFrame")) {
            MsgBox("Opera PMS 未启动", POPUP_TITLE, "4096 T1 iconx")
            return
        }

        WinActivate("ahk_class SunAwtFrame")
        Sleep(200)

        found := PmsImageFinder.find("opera-active-win.png")
        if (!found) {
            return
        }

        CoordMode("Mouse", "Screen")
        A_Clipboard := ""
        MouseClickDrag("Left", found.outX + 120, found.outY + 302, found.outX, found.outY + 302)
        Sleep(200)
        Send("^c")
        if (!ClipWait(2)) {
            MsgBox("复制房号失败，请在预订界面中重试", POPUP_TITLE, "4096 T2 iconx")
            return
        }
        curRoomNum := A_Clipboard
        Sleep(200)

        ; perform room move in pms
        Send("!t")
        utils.waitLoading()
        Send("!v")
        utils.waitLoading()
        Send("{Text}" . newRoomNum)
        utils.waitLoading()
        Send("!o")
        utils.waitLoading()

        ; handle alert
        alertFound := PmsImageFinder.find("alert.png")
        Sleep(100)
        errorFound := PmsImageFinder.find("alert.png")
        if (alertFound || errorFound) {
            res := MsgBox("检测到警告弹窗，请处理后继续", POPUP_TITLE, "4096 iconi OKCancel")
            if (res == "Cancel") {
                return
            }
        }

        Send(this.roomStatusKeyMap[prevRoomStatus])
        utils.waitLoading()


        Landow.createRoomMove(curRoomNum, newRoomNum, reason)
    }
}