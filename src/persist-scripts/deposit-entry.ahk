class DepositEntry {
    static regex := {
        union: "",
        visa: "^4\d{12}(\d{3})?$",
        master: "^(5[1-5]\d{14}|2(2[2-9]\d{12}|[3-6]\d{13}|7[01]\d{12}|720\d{12}))$",
        amex: "^3[47]\d{13}$",
        jcb: "^35(2[89]|[3-8]\d)\d{12}$"
    }

    static USE(isListening) {
        if (!isListening) {
            return
        }

        
    }

    static validate(card){
        message := "Card No.:{1} is a {2} card."

        switch {
            case RegExMatch(card, this.regex.visa):
                msgbox(Format(message, card, "Visa"))

            case RegExMatch(card, this.regex.master):
                msgbox(Format(message, card, "Master"))
            
            case RegExMatch(card, this.regex.amex):
                msgbox(Format(message, card, "Amex"))
            
            case RegExMatch(card, this.regex.jcb):
                msgbox(Format(message, card, "JCB"))
            
            default:
                msgbox(Format(message, card, "UnionPay"))       
        }
    }
}