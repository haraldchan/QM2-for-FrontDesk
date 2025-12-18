/**
 * @typedef {Object} Deposit
 * @property {"VS" | "MC" | "AE" | "JC" | "UP"} cardType
 * @property {String} cardNum
 * @property {String} exp
 * @property {String} amount
 * @property {String} auth
 */

class DepositEntry {
    static regex := {
        visa: "^4\d{12}(\d{3})?$",
        master: "^(5[1-5]\d{14}|2(2[2-9]\d{12}|[3-6]\d{13}|7[01]\d{12}|720\d{12}))$",
        amex: "^3[47]\d{13}$",
        jcb: "^35(2[89]|[3-8]\d)\d{12}$"
    }

    /**
     * @param {Gui.CheckBox} controlCheckBox 
     */
    static USE(controlCheckBox) {
        if (controlCheckBox.Value == false || !RegExMatch(A_Clipboard, "^;\d+=\d+\?$")) {
            return
        }
        
        ; dismiss success popup
        Send "{Enter}"
        Sleep 200
            
        parsedCard := A_Clipboard.replaceThese([";", "?"]).split("=")
        A_Clipboard := " "

        cardType := this.validateType(parsedCard[1]),
            cardNum := parsedCard[1],
            exp := parsedCard[2].substr(3, 4) . parsedCard[2].substr(1, 2),
            auth := cardType == "UP" && (cardNum.startsWith(1) || cardNum.startsWith(2))
                ? cardNum.substr(1, 1) . cardNum.substr(-5)
            : ""

        depositInfo := {
            cardType: cardType,
            cardNum: cardNum,
            exp: exp,
            amount: "",
            auth: auth
        }

        this.promptCompleteInfo(depositInfo)
    }

    /**
     * @param {Deposit} depositInfo 
     */
    static promptCompleteInfo(depositInfo) {
        Prompt := Gui("+AlwaysOnTop")
        Prompt.SetFont(, "微软雅黑")
        Prompt.OnEvent("Close", p => p.Destroy())

        destroyPrompt(*) => Prompt.Destroy()
        
        completeInfo(*) {
            depositInfo.cardType := Prompt.getCtrlByTypeAll("Radio")
                                          .find(radio => radio.Value == true)
                                          .Text
                                          .replace("&", "")
            depositInfo.cardNum := Prompt["card-num"].Value
            depositInfo.exp := Prompt["exp"].Value
            depositInfo.amount := Prompt["amount"].Value
            depositInfo.auth := Prompt["auth"].Value

            destroyPrompt()
            this.entry(depositInfo)
        }


        onMount() {
            Prompt.Show()
        
            Prompt[depositInfo.cardType].Value := true
            Prompt["amount"].Focus()
        }

        return (
            Prompt.AddGroupBox("Section w330 r7", "押金信息"),
            ; card type
            Prompt.AddText("xs10 yp+23 w80 h25 0x200", "支付类型"),
            Prompt.AddRadio("x+1 w45 h25", "&UP"),
            Prompt.AddRadio("x+1 w45 h25", "&VS"),
            Prompt.AddRadio("x+1 w45 h25", "&MC"),
            Prompt.AddRadio("x+1 w45 h25", "&AE"),
            Prompt.AddRadio("x+1 w45 h25", "&JC"),
            
            ; card info
            Prompt.AddText("xs10 yp+30 w80 h25 0x200", "卡号信息"),
            Prompt.AddEdit("vcard-num x+1 w150 h25 0x200", depositInfo.cardNum),
            Prompt.AddEdit("vexp x+1 w70 h25", depositInfo.exp),

            ; amount auth
            Prompt.AddText("xs10 yp+30 w80 h25 0x200", "金额/授权号"),
            Prompt.AddEdit("vamount x+1 w150 h25 0x200", ""),
            Prompt.AddEdit("vauth x+1 w70 h25 0x200", depositInfo.auth),

            ; btns
            Prompt.AddButton("xs150 yp+40 w80 h25", "取消 (&C)")
                  .OnEvent("Click", destroyPrompt),
            Prompt.AddButton("x+5 w80 h25", "确定 (&O)")
                  .OnEvent("Click", completeInfo),

            onMount()
        )
    }

    /**
     * @param {String} cardNum 
     * @returns {"VS" | "MC" | "AE" | "JC" | "UP"} 
     */
    static validateType(cardNum) {
        message := "Card No.:{1} is a {2} card."

        switch {
            ; Visa
            case RegExMatch(cardNum, this.regex.visa):
                return "VS"
                ; MasterCard
            case RegExMatch(cardNum, this.regex.master):
                return "MC"
                ; Amex
            case RegExMatch(cardNum, this.regex.amex):
                return "AE"
                ; JCB
            case RegExMatch(cardNum, this.regex.jcb):
                return "JC"
                ; Union Pay
            default:
                return "UP"
        }
    }

    /**
     * @param {Deposit} depositInfo 
     */
    static entry(depositInfo) {
        if (!WinExist("ahk_class SunAwtFrame")) {
            return
        }

        WinActivate("ahk_class SunAwtFrame")
        loop {
            if (ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-active-win.PNG"])) {
                break
            }
            Sleep 200
        } until (A_Index > 5)

        ; move to payment field
        MouseMove outX + 447, outY + 257
        utils.waitLoading()
        Click 3
        Sleep 100
        Send "{Text}" . depositInfo.cardType
        Send "{Tab}"
        utils.waitLoading()

        CoordMode("Pixel", "Screen")
        if (PixelGetColor(outX  + 130, outY + 164) == "0x000080") {
            Send "!c"
            utils.waitLoading()
        }

        ; attach card to profile prompt, choose "No"
        loop {
            if (ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["alert.PNG"])) {
                break
            }

            Sleep 200
        } until (A_Index > 5)
        Send "{Esc}"
        utils.waitLoading()

        ; enter cardNum & exp
        Send "{Text}" . depositInfo.cardNum
        Send "{Tab}"
        Send "{Text}" . depositInfo.exp
        Send "!s"
        utils.waitLoading()
        loop 3 {
            Send "{Esc}"
            utils.waitLoading()
        }

        ; enter deposit amount & auth
        Send "!t"
        utils.waitLoading()
        Send "!e"
        Send "!a"
        Send "!m"
        utils.waitLoading()
        Send "{Text}" . depositInfo.amount
        Send "{Tab}"
        Send "{Text}" . depositInfo.auth
        Send "!o"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
    }
}
