#Include action-modules\action-module-index.ahk

/**
 * @param {Svaner} App 
 */
OnePress(App) {
    modules := OrderedMap(
        "生成空白(NRR) Share", BlankShare,
        "生成 PayBy PayFor 信息", PaymentRelation,
        "入账关联 - 快速打开Billing、入Deposit等", Cashiering,
        "批量房卡制作 (Excel 表辅助)", BatchKeysXl,
        "批量房卡制作 (连续输入)", BatchKeysSq,
        "抓取 FedEx Opera 订单信息", FetchFedexResv,
        "快速查看房价", RateChecking
    )

    selectedModule := signal(modules.keys()[1])

    handleModuleChange(ctrl, _) {
        moduleName := modules[ctrl.Text].name
        selectedModule.set(ctrl.Text)

        for desc, module in modules {
            App[module.name.toCase("kebab") . "-action"].Opt(desc == ctrl.Text ? "+Default" : "-Default")
        }
        WinSetAlwaysOnTop (moduleName == "PaymentRelation"), POPUP_TITLE
    }

    App.defineDirectives(
        "@use:box-x", "x30",
        "@use:box-w", "w350",
        "@use:bold", ctrl => ctrl.setFont("bold"),
        "@use:box", "@use:box-x @relative[y+10]:op-radio-group @use:box-w @use:bold",
        "@use:form-text", "xs10 yp+30 w100 h25 0x200",
        "@use:form-edit", "x+10 w200 h25 0x200"
    )

    onMount() {
        SetTimer(focusFirstRadio)
        focusFirstRadio(*) {
            if (WinExist(POPUP_TITLE)) {
                ControlClick(App["component:$op-radio-group"].ctrls.find(c => c is Gui.Radio))
                SetTimer(, 0)
            }
        }
    }

    return (
        StackBox(App, 
            {
                name: "op-radio-group",
                groupbox: { options: "vop-radio-group Section x30 y+10 w350 Hidden " . Format("h{1}", 30 * modules.keys().Length) } 
            },
            () => modules.entries().map((entry, index) => 
                App.AddRadio(index == 1 ? "xs1 h20 yp+1" : "xs1 h20 yp+30" , entry[1]).onClick(handleModuleChange)
            )
        ),
        Dynamic(App, selectedModule, modules),
        
        onMount()
    )
}