class RateChecking_Action {
    static start() {
        this.isRunning := true
        HotIf (*) => this.isRunning
        Hotkey("F12", (*) => this.end(), "On")

        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        Sleep 500
        ; WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        ; BlockInput true
    }

    static end() {
        this.isRunning := false
        Hotkey("F12", "Off")

        ; BlockInput false
        ; WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
    }

    static USE(confNums) {
        this.start()
        
        parsedConfNums := this.parseConfNums(confNums)
        this.checkRate(parsedConfNums)

        this.end()
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
            ; use existing rate checking script here
        }
    }
}