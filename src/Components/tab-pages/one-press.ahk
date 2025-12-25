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
        moduleName := modules[ctrl.Text]
        selectedModule.set(ctrl.Text)

        for desc, module in modules {
            App[StrLower(module.name) . "-action"].Opt(desc == ctrl.Text ? "+Default" : "-Default")
        }
        WinSetAlwaysOnTop (moduleName == "PaymentRelation"), POPUP_TITLE
    }

    App.defineDirectives(
        "@use:box-x", "x30",
        "@use:box-w", "w350",
        "@use:box-xyw", "@use:box-x @relative[y+10]:last-radio @use:box-w"
    )

    defineRadioStyle(index) {
        switch index {
            case 1:
                return "vfirst-radio Checked x30 y+10 h20"
            case modules.keys().Length:
                return "vlast-radio x30 y+10 h20"
            default:
                return "x30 y+10 h20"
        }
    }

    return (
        modules.keys().map(desc =>
            App.AddRadio(defineRadioStyle(A_Index), desc)
               .onClick(handleModuleChange)
        ),
        ; Dynamic(App, selectedModule, moduleComponents),
        Dynamic(App, selectedModule, modules),
        App[StrLower(modules[selectedModule.value].name) . "-action"].Opt("+Default")
    )
}