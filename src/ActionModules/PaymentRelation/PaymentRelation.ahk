#Include "./PaymentRelation_Action.ahk"

class PaymentRelation extends Component {
    static name := "PaymentRelation"
    static description := "生成 PayBy PayFor 信息"

    __New(App) {
        super.__New("PaymentRelation")
        this.App := App
        this.render(App)
    }

    action() {
        this.App.Hide()
        Sleep 100
        PaymentRelation_Action.USE()
        this.App.Show()
    }

    getFormData(App) {
        return Map(
            "pfRoom", App.getCtrlByName("pfRoom").Value,
            "pfName", App.getCtrlByName("pfName").Value,      
            "party", App.getCtrlByName("party").Value,
            "roomQty", App.getCtrlByName("roomQty").Value,
            "pfCopy", App.getCtrlByName("pfCopy").Value,
            "pbRoom", App.getCtrlByName("pbRoom").Value,
            "pbName", App.getCtrlByName("pbName").Value
        )
    }

    getPayFor(App) {
        form := this.getFormData(App)
        for field in form {
            if (field = "") {
                return
            }
        }

        nameConf := IsNumber(form["pbName"]) ? "#" . form["pbName"] : form["pbName"]
        if (form["party"] = "" || form["roomQty"] = "") {
            ; 2-room party
            A_Clipboard := Format("P/F Rm{1} {2}  ", form["pbRoom"], nameConf)
        } else {
            ; 3 or more room party
            A_Clipboard := Format("P/F Party#{1}, total {2}-rooms  ", form["party"], form["roomQty"])

        }
        MsgBox(A_Clipboard, "已复制信息", "4096 T1")
    }

    getPayBy(App) {
        form := this.getFormData(App)
        for field in form {
            if (field = "") {
                return
            }
        }

        nameConf := IsNumber(form["pfName"]) ? "#" . form["pfName"] : form["pfName"]
        A_Clipboard := Format("P/B Rm{1} {2}  ", form["pfRoom"], nameConf)
        MsgBox(A_Clipboard, "已复制信息", "4096 T1")
    }

    render(App) {
        return super.Add(
            ; pay for
            App.AddGroupBox("Section x30 y400 w170 r7", "P/F房(支付人)"),
            App.AddText("xs10 yp+25 h20 0x200", "房号         "),
            App.AddEdit("vpfRoom Number x+10 w80 h20", ""),
            App.AddText("xs10 y+10 h20 0x200", "姓名/确认号 "),
            App.AddEdit("vpfName x+1 w80 h20", ""),
            App.AddText("xs10 y+10 h20 0x200", "Party号     "),
            App.AddEdit("vparty Number x+10 w80 h20", ""),
            App.AddText("xs10 y+10 h20 0x200", "Total房数  "),
            App.AddEdit("vroomQty Number x+10 w80 h20", ""),
            App.AddReactiveButton("vpfCopy xs10 y+10 h30 w150", "复制Pay For信息")
               .OnEvent("Click", (*) => this.getPayFor(App)),

            ; pay by
            App.AddGroupBox("Section x210 y400 w170 r7", "P/B房(被支付人)"),
            App.AddText("xs10 yp+25 h20 0x200", "房号         "),
            App.AddEdit("vpbRoom Number x+10 w80 h20", ""),
            App.AddText("xs10 y+10 h20 0x200", "姓名/确认号 "),
            App.AddEdit("vpbName x+1 w80 h20", ""),
            App.AddReactiveButton("vpbCopy xs10 y+70 h30 w150", "复制Pay By信息")
               .OnEvent("Click", (*) => this.getPayBy(App)),

            ;execute
            App.AddReactiveButton("vPaymentRelationAction w350 h40 x30 y+25", "粘 贴 信 息")
               .OnEvent("Click", (*) => this.action())
        )
    }
}