#Include "./Cashiering_Action.ahk"

class Cashiering extends Component {
    static name := "Cashiering"
    static description := "入账关联 - 快速打开Billing、入Deposit等"

    __New(App) {
        super.__New("Cashiering")
        this.App := App

        this.hotStringCommands := "
        (
            输入:pw   - 快速输入密码
            输入:agd  - 生成Agoda BalanceTransfer
            输入:blk  - Blocks 界面打开PM (主管权限)
            Alt+F11   - InHouse 界面打开Billing
            Win+F11   - 录入 Deposit
        )"

        this.paymentType := Map(
            9002, "9002 - Bank Transfer",
            9132, "9132 - Alipay",
            9138, "9138 - EFT-Wechat",
            9140, "9140 - EFT-Alipay",
        )

        this.password := ""

        this.render(App)
        this.bindHotKeys()
    }

    getFormData() {
        return {
            password: this.App.getCtrlByName("pwd").Value,
            paymentType: this.paymentType.getKey(this.App.getCtrlByName("pt").Text)
        }
    }

    bindHotKeys() {
        HotIf (*) => this.getFormData().password != ""
        ; hot keys        
        Hotkey "!F11", (*) => Cashiering_Action.openBilling(this.getFormData())
        Hotkey "#F11", (*) => Cashiering_Action.depositEntry(this.getFormData())
        ; hot strings
        Hotstring "::pw", (*) => Cashiering_Action.sendPassword(this.getFormData())
        Hotstring "::agd", (*) => Cashiering_Action.agodaBalanceTransfer()
        Hotstring "::blk", (*) => Cashiering_Action.blockPmBilling(this.getFormData())
    }

    handlePwsVisible(ctrl) {
        this.App.getCtrlByName("pwd").Opt(ctrl.Value = false ? "+Password*" : "-Password*")
    }

    render(App) {
        super.Add(
            App.AddGroupBox("Section w350 x30 y400 r10", "入账关联"),
            
            ; opera password
            App.AddText("xs10 yp+30 h20", "Opera 密码"),
            App.AddReactiveEdit("vpwd Password* h20 w200 x+10", "")
               .OnEvent("LoseFocus", (ctrl, _) => this.password := ctrl.Value),
            App.AddReactiveCheckBox("h20 x+10", "显示")
               .OnEvent("Click", (ctrl, _) => this.handlePwsVisible(ctrl)),

            ; hot string commands list
            App.AddGroupBox("r4 xs10 yp+25 w330", "快捷指令 "),
            StrSplit(this.hotStringCommands, "`n").map(fragment =>
                App.AddText((A_Index = 1 ? "xp+10 " : "") . "yp+20", fragment)
            ),
            ; deposit payments
            App.AddGroupBox("r2 xs10 y+10 w330", " Deposit "),
            App.AddText("xp+10 yp+30 h25 0x200", "支付类型"),
            App.AddDropDownList("vpt x+10 w130 Choose2", this.paymentType.values()),
            App.AddReactiveButton("vCashieringAction x+13 w100 h25", "录入 Deposit")
               .OnEvent("Click", (*) => Cashiering_Action.depositEntry(this.getFormData())),
        )
    }
}