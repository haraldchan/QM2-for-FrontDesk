class RateChecking_Action {
    static start() {
        this.isRunning := true
        HotIf (*) => this.isRunning
        Hotkey("F12", (*) => this.end(), "On")

        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        Sleep 500
    }

    static end() {
        this.isRunning := false
        Hotkey("F12", "Off")
    }

    static USE(confNums) {        
        parsedConfNums := this.parseConfNums(confNums)
        this.checkRate(parsedConfNums)
    }

    static parseConfNums(confNums) {
        splitted := confNums.split(" ")
        parsed := []

        for confNum in splitted {
            if (A_Index == 1) {
                parsed.Push(confNum)
                continue
            }

            if (StrLen(confNum) < StrLen(splitted[1])) {
                moddedConfNum := splitted[1].split("")
                                            .slice(1, StrLen(splitted[1]) - StrLen(confNum) + 1)
                                            .append(confNum)
                                            .join("")
                parsed.Push(moddedConfNum)
            } else {
                parsed.Push(confNum)
            }
        }

        return parsed
    }

    static checkRate(confNums) {
        for confNum in confNums {
            this.start()
            
            ; clear -> search for confNum
            Send "!r"
            loop 6 {
                Send "{Tab}"
            }
            Sleep 100
            Send "{Text}" . confNum
            utils.waitLoading()
            Send "!h"
            utils.waitLoading()

            ; skip if not found
            if (ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["info.png"])) {
                Send "{Enter}"
                utils.waitLoading()
                continue
            }

            ; show room rate
            showRate := msgbox("打开 Rate Info?",,"OKCANCEL 4096")
            if (showRate == "Cancel") {
                continue
            }            
            Send "!t"
            utils.waitLoading()
            Send "!f"
            utils.waitLoading()

            if (msgbox("关闭当前预订",, "OK 4096") == "OK") {
                Send "!c"
                utils.waitLoading()
                Send "!c"
                utils.waitLoading()
            }
        }
    }
}
