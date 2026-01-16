#Include cashiering-action.ahk

/**
 * @param {Svaner} App 
 * @param {Object} [props] 
 * @returns {Component} 
 */
Cashiering(App, props) {
    comp := Component(App, A_ThisFunc)

    password := signal("")

    hotStringCommands := "
    (
        输入:pw`t`t- 快速输入密码
        输入:agd`t- 生成Agoda BalanceTransfer
        输入:blk`t`t- Blocks 界面打开PM (主管权限)
        热键:Alt+F11`t- InHouse 界面打开Billing
        热键:Win+F11`t- 录入 Deposit
    )"

    paymentType := Map(
        9002, "9002 - Bank Transfer",
        9132, "9132 - Alipay",
        9138, "9138 - EFT-Wechat",
        9140, "9140 - EFT-Alipay",
    )

    getFormData() {
        return {
            password: App["pwd"].Value,
            paymentType: paymentType.getKey(App["pt"].Text)
        }
    }

    handlePwsVisible(ctrl, _) {
        App["pwd"].Opt(ctrl.Value = false ? "+Password*" : "-Password*")
    }

    setHotkeys() {
        HotIf((*) => getFormData().password),
            ; hot keys
            Hotkey("!F11", (*) => Cashiering_Action.openBilling(getFormData())),
            Hotkey("#F11", (*) => Cashiering_Action.depositEntry(getFormData())),
            ; hot strings
            Hotstring("::pw", (*) => Cashiering_Action.sendPassword(getFormData())),
            Hotstring("::agd", (*) => Cashiering_Action.agodaBalanceTransfer()),
            Hotstring("::blk", (*) => Cashiering_Action.blockPmBilling(getFormData()))
    }
    setHotkeys()

    comp.render := (this) => this.Add(
        StackBox(App, 
            {
                name: "cashiering-stack-box",
                groupbox: {
                    title: "入账关联",
                    options: "Section r11 @use:box",
                }
            },
            () => [
                ; opera password
                App.AddText("xs10 yp+30 h20", "Opera 密码"),
                App.AddEdit("vpwd Password* h20 w200 x+10", "{1}", password).bind(),
                App.AddCheckBox("h20 x+10", "显示").onClick(handlePwsVisible),
                
                ; hot string commands list
                App.AddGroupBox("r5 xs10 yp+25 w330", "快捷指令 "),
                hotStringCommands.split("`n").map(fragment =>
                    App.AddText((A_Index = 1 ? "xp+10 " : "") . "yp+20", fragment)
                ),

                ; deposit payments
                App.AddGroupBox("r2 xs10 y+10 w330", " Deposit "),
                App.AddText("xp+10 yp+30 h25 0x200", "支付类型"),
                App.AddDDL("vpt x+10 w130 Choose2", paymentType.values()),
                App.AddButton("vcashiering-action x+13 w100 h25", "录入 Deposit")
                   .onClick((*) => Cashiering_Action.depositEntry(getFormData())),
            ]
        )
    )

    return comp
}
