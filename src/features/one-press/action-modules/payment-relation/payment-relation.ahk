#Include payment-relation-action.ahk

/** 
 * @param {Svaner} App
 * @param {Object} [props] 
 * @returns {Component} 
 */
PaymentRelation(App, props := {}) {
    ( !props.hasOwnProp("style") && props.styles := {} )
    s := useProps(props.styles, {
        useCopyBtn: true,
        panelWide: "w170 ",
        rPanelXPos: "x210 "
    })

    ( !props.hasOwnProp("form") && props.form := {} )
    f := useProps(props.form, {
        pfRoom: "",
        pfName: "",
        party:  "",
        partyRoomQty: "",
        pbRoom: "",
        pbName: ""
    })

    comp := Component(App, A_ThisFunc)
    pasteSingle := signal(s.useCopyBtn)
    actionType := computed(pasteSingle, isSingle => isSingle ? "粘 贴 信 息" : "录 入 全 部")

    getPayFor(*) {
        form := comp.submit()

        nameConf := IsNumber(form.pbName) ? "#" . form.pbName : form.pbName
        A_Clipboard := (!form.party || !form.partyRoomQty)
            ? Format("P/F Rm{1} {2}  ", form.pbRoom, nameConf)
            : Format("P/F Party#{1}, total {2}-rooms  ", form.party, form.partyRoomQty)
        MsgBox(A_Clipboard, "已复制信息", "4096 T1")
    }

    getPayBy(*) {
        form := comp.submit()

        nameConf := IsNumber(form.pfName) ? "#" . form.pfName : form.pfName
        A_Clipboard := Format("P/B Rm{1} {2}  ", form.pfRoom, nameConf)
        MsgBox(A_Clipboard, "已复制信息", "4096 T1")
    }

    clear(*) {
        for ctrl in comp.ctrls {
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

        form := comp.submit()
        PaymentRelation_Action.USE(pasteSingle.value ? "" : form)
        App.Show()
    }

    App.defineDirectives(
        "@use:pr-text", "xs10 yp+25 w70 h20 0x200",
        "@use:pr-edit", "x+1 w80 h20"
    )

    comp.render := (this) => this.Add(
        StackBox(App, 
            {
                name: "pay-for-stack-box",
                groupbox: {
                    title: "P/F房(支付人)",
                    options: "vpayfor-panel Section @use:box-x @relative[y+10]:last-radio" . (s.useCopyBtn ? " r7 " : " r5 ") . s.panelWide
                } 
            },
            () => [
                ; pay for
                App.AddText("@use:pr-text yp+20", "房号"),
                App.AddEdit("vpf-room Number @use:pr-edit", f.pfRoom),

                App.AddText("@use:pr-text", "姓名/确认号 "),
                App.AddEdit("vpf-name @use:pr-edit", f.pfName),
                
                App.AddText("@use:pr-text", "Party号"),
                App.AddEdit("vparty Number @use:pr-edit", f.party),
                
                App.AddText("@use:pr-text", "Total房数"),
                App.AddEdit("vparty-room-qty Number @use:pr-edit", f.partyRoomQty),

                ; copy btn
                s.useCopyBtn && App.AddButton("vpf-copy xs10 y+10 h30 w150", "复制Pay For信息").onClick(getPayFor),  
            ]
        ),

        StackBox(App,
            {
                name: "pay-by-stack-box",
                groupbox: {
                    title: "P/B房(被支付人)",
                    options: "vpayby-panel Section x+3 @align[yw]:payfor-panel" . (s.useCopyBtn ? " r7 " : " r5 ")
                }
            },
            () => [
                ; pay by
                App.AddText("@use:pr-text yp+20", "房号"),
                App.AddEdit("vpb-room Number @use:pr-edit", f.pbRoom),
                App.AddText("@use:pr-text", "姓名/确认号 "),
                App.AddEdit("vpb-name @use:pr-edit", f.pbName),
                ; copy btn
                s.useCopyBtn && App.AddButton("vpb-copy xs10 @align[ywh]:pf-copy", "复制Pay By信息").onClick(getPayBy),
            ]
        ),

        ; btns  
        App.AddButton("vpaymentrelation-action w300 h40 @align[x]:payfor-panel" . (s.useCopyBtn ? " y+25 " : " y+75 "), "{1}", actionType)
           .onClick(action)
           .onContextMenu(handlePasteModeSwitch),
        App.AddButton("w40 h40 x+10", "清空").onClick(clear)
    )

    return comp
}