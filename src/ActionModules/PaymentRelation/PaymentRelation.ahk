#Include "./PaymentRelation_Action.ahk"

PaymentRelation(props) {
    App := props.App, 
    styles := props.styles

    pr := Component(App, A_ThisFunc)

    getPayFor() {
        form := pr.submit()

        nameConf := IsNumber(form.pbName) ? "#" . form.pbName : form.pbName
        A_Clipboard := (form.party = "" || form.roomQty = "")
            ? Format("P/F Rm{1} {2}  ", form.pbRoom, nameConf)
                : Format("P/F Party#{1}, total {2}-rooms  ", form.party, form.roomQty)
        MsgBox(A_Clipboard, "已复制信息", "4096 T1")
    }

    getPayBy() {
        form := pr.submit()

        nameConf := IsNumber(form.pfName) ? "#" . form.pfName : form.pfName
        A_Clipboard := Format("P/B Rm{1} {2}  ", form.pfRoom, nameConf)
        MsgBox(A_Clipboard, "已复制信息", "4096 T1")
    }

    action() {
        App.Hide()
        Sleep 100
        PaymentRelation_Action.USE()
        App.Show()
    }

    pr.render := (this) => this.Add(
        ; pay for
        App.AddGroupBox("Section w170 r7 " . styles.xPos . styles.yPos, "P/F房(支付人)"),
        App.AddText("xs10 yp+25 h20 0x200", "房号         "),
        App.AddEdit("vpfRoom Number x+10 w80 h20", ""),
        App.AddText("xs10 y+10 h20 0x200", "姓名/确认号 "),
        App.AddEdit("vpfName x+1 w80 h20", ""),
        App.AddText("xs10 y+10 h20 0x200", "Party号     "),
        App.AddEdit("vparty Number x+10 w80 h20", ""),
        App.AddText("xs10 y+10 h20 0x200", "Total房数  "),
        App.AddEdit("vroomQty Number x+10 w80 h20", ""),
        App.AddReactiveButton("vpfCopy xs10 y+10 h30 w150", "复制Pay For信息")
           .OnEvent("Click", (*) => getPayFor()),
        ; pay by
        App.AddGroupBox("Section x210 w170 r7 " . styles.yPos, "P/B房(被支付人)"),
        App.AddText("xs10 yp+25 h20 0x200", "房号         "),
        App.AddEdit("vpbRoom Number x+10 w80 h20", ""),
        App.AddText("xs10 y+10 h20 0x200", "姓名/确认号 "),
        App.AddEdit("vpbName x+1 w80 h20", ""),
        App.AddReactiveButton("vpbCopy xs10 y+70 h30 w150", "复制Pay By信息")
           .OnEvent("Click", (*) => getPayBy()),
        ;execute
        App.AddReactiveButton("vPaymentRelationAction h40 y+25 " . styles.wide . styles.xPos, "粘 贴 信 息")
           .OnEvent("Click", (*) => action())
    )

    return pr
}