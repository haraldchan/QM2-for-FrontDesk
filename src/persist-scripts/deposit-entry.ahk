class DepositEntry {
    static regex := {
        visa: "^4\d{12}(\d{3})?$",
        master: "^(5[1-5]\d{14}|2(2[2-9]\d{12}|[3-6]\d{13}|7[01]\d{12}|720\d{12}))$",
        amex: "^3[47]\d{13}$",
        jcb: "^35(2[89]|[3-8]\d)\d{12}$"
    }

    static USE(controlCheckBox) {
        if (controlCheckBox.Value == false) {
            return
        }

        if (RegExMatch(A_Clipboard, "^;\d+=\d+\?$")) {
            parsedCard := A_Clipboard.replaceThese([";", "?"]).split("=")

            cardType := this.validateType(parsedCard[1]),
            cardNum := parsedCard[1],
            exp := parsedCard[2].substr(3, 4) . parsedCard[2].substr(1, 2),
            auth :=  cardType == "UP" && (cardNum.startsWith(1) || cardNum.startsWith(2))
                ? cardNum.substr(1, 1) . cardNum.substr(-5)
                : ""
            
            depositInfo := {
                cardType: cardType,
                cardNum: cardNum,
                exp: exp,
                auth: auth
            }
        }
    }

    static validateType(card){
        message := "Card No.:{1} is a {2} card."

        switch {
            ; Visa
            case RegExMatch(card, this.regex.visa):
                return { cardType: "VS" }
            ; MasterCard
            case RegExMatch(card, this.regex.master):
                return "MC"
            
            ; Amex
            case RegExMatch(card, this.regex.amex):
                return "AE"
            
            ; JCB
            case RegExMatch(card, this.regex.jcb):
                return "JC"
            
            ; Union Pay
            default:
                return "UP"      
        }
    }
}
