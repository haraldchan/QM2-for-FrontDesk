#Include "./PaymentRelation_Action.ahk"

PaymentRelation(props) {
    App := props.App, 
    s := useProps(props.styles, {
        useCopyBtn: true,
        xPos: "x30 ",
        yPos: "y460 ",
        wide: "w350 ",
        panelWide: "w170 ",
        rPanelXPos: "x210 "
    })

    pr := Component(App, A_ThisFunc)
    pasteSingle := signal(s.useCopyBtn)
    actionType := computed(pasteSingle, isSingle => isSingle ? "粘 贴 信 息" : "录 入 全 部")

    getPayFor(*) {
        form := pr.submit()

        nameConf := IsNumber(form.pbName) ? "#" . form.pbName : form.pbName
        A_Clipboard := (!form.party || !form.partyRoomQty)
            ? Format("P/F Rm{1} {2}  ", form.pbRoom, nameConf)
            : Format("P/F Party#{1}, total {2}-rooms  ", form.party, form.partyRoomQty)
        MsgBox(A_Clipboard, "已复制信息", "4096 T1")
    }

    getPayBy(*) {
        form := pr.submit()

        nameConf := IsNumber(form.pfName) ? "#" . form.pfName : form.pfName
        A_Clipboard := Format("P/B Rm{1} {2}  ", form.pfRoom, nameConf)
        MsgBox(A_Clipboard, "已复制信息", "4096 T1")
    }

    clear(*) {
        for ctrl in pr.ctrls {
            if (ctrl is Gui.Edit) {
                ctrl.Value := ""
            }
        }
    }

    handlePasteModeSwitch(*) {
        if (!s.useCopyBtn) {
            return
        }

        pasteSingle.set(s => !s)
    }

    action(*) {
        App.Hide()
        Sleep 100

        form := pr.submit()
        PaymentRelation_Action.USE(pasteSingle.value ? "" : form)
        App.Show()
    }

    pr.render := (this) => this.Add(
        ; pay for
        App.AddGroupBox("Section " . (s.useCopyBtn ? "r7 " : "r5 ") . s.panelWide . s.xPos . s.yPos, "P/F房(支付人)"),
        App.AddText("xs10 yp+25 h20 0x200", "房号         "),
        App.AddEdit("vpfRoom Number x+10 w80 h20", ""),
        App.AddText("xs10 y+10 h20 0x200", "姓名/确认号 "),
        App.AddEdit("vpfName x+1 w80 h20", ""),
        App.AddText("xs10 y+10 h20 0x200", "Party号     "),
        App.AddEdit("vparty Number x+10 w80 h20", ""),
        App.AddText("xs10 y+10 h20 0x200", "Total房数  "),
        App.AddEdit("vpartyRoomQty Number x+10 w80 h20", ""),
        ; copy btn
        s.useCopyBtn && App.AddReactiveButton("vpfCopy xs10 y+10 h30 w150", "复制Pay For信息").OnEvent("Click", getPayFor),
        
        ; pay by
        App.AddGroupBox("Section " . (s.useCopyBtn ? "r7 " : "r5 ") . s.rPanelXPos . s.yPos . s.panelWide, "P/B房(被支付人)"),
        App.AddText("xs10 yp+25 h20 0x200", "房号         "),
        App.AddEdit("vpbRoom Number x+10 w80 h20", ""),
        App.AddText("xs10 y+10 h20 0x200", "姓名/确认号 "),
        App.AddEdit("vpbName x+1 w80 h20", ""),
        ; copy btn
        s.useCopyBtn && App.AddReactiveButton("vpbCopy xs10 y+70 h30 w150", "复制Pay By信息").OnEvent("Click", getPayBy),
        
        ; btns  
        App.ARButton("vPaymentRelationAction w300 h40 " . (s.useCopyBtn ? "y+25 " : "y+75 ") . s.xPos, "{1}", actionType)
           .OnEvent(
                "Click", action,
                "ContextMenu", handlePasteModeSwitch
            ),
        App.ARButton("w40 h40 x+10", "清空").OnEvent("Click", clear)
    )

    return pr
}