;utils: general utility methods
class utils {
    /**
     * Reset windows and key states.
     * @param {Array} winGroup Windows to release.
     * @param {true | false} quit Exit app on reload.
     */
    static cleanReload(winGroup, quit := 0) {
        ; Windows set default
        loop winGroup.Length {
            if (WinExist(winGroup[A_Index])) {
                WinSetAlwaysOnTop(false, winGroup[A_Index])
            }
        }
        ; Key/Mouse state set default
        BlockInput(false)
        SetCapsLockState(false)
        CoordMode("Mouse", "Screen")
        if (quit = "quit") {
            ExitApp()
        }
        Reload()
    }

    /**
     * 
     * @param {String} appName 
     * @param {String} popupTitle 
     * @param {Array} winGroup 
     */
    static quitApp(appName, popupTitle, winGroup) {
        quitConfirm := MsgBox(Format("是否退出 {1}？", appName), popupTitle, "OKCancel 4096")
        quitConfirm = "OK" ? this.cleanReload(winGroup, true) : this.cleanReload(winGroup)
    }

    /**
     * 
     * @param {Integer} interval waiting interval in ms.
     */
    static waitLoading(interval := 250) {
        loop {
            sleep(interval)
            if (A_Cursor != "Wait") {
                break
            }
        }
    }
}