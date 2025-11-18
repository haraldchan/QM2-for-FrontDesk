OnePress(App) {
    modules := OrderedMap(
        BlankShare,       "生成空白(NRR) Share",
        PaymentRelation,  "生成 PayBy PayFor 信息",
        Cashiering,       "入账关联 - 快速打开Billing、入Deposit等",
        GroupShareDnm,    "预抵房间批量 Share/DoNotMove",
        ; PsbBatchUpload,   "旅业二期（网页版）批量上报",
        ; PsbBatchCheckout, "旅业二期（网页版）批量退房",
        BatchKeysXl,      "批量房卡制作（Excel 表辅助）", 
        BatchKeysSq,      "批量房卡制作（连续输入）", 
        FetchFedexResv,   "抓取 FedEx Opera 订单信息",
        ; BriefingSheets,   "生成 Briefing 报表",
        RateChecking,     "快速查看房价"
    )

    selectedModule := signal(modules.keys()[1].name)
    moduleComponents := OrderedMap()
    for module in modules {
        moduleComponents[module.name] := module
    }

    effect(selectedModule, handleModuleChange)
    handleModuleChange(moduleName) {
        for module in modules {
            App.getCtrlByName(module.name . "Action").Opt(module.name = moduleName ? "+Default" : "-Default")
        }
        WinSetAlwaysOnTop (moduleName = "PaymentRelation"), POPUP_TITLE
    }

    return (
        modules.keys().map(module =>
            App.AddRadio(A_Index = 1 ? "vfirstRadio Checked x30 y+10 h20" : "x30 y+10 h20", modules[module])
               .OnEvent("Click", (*) => selectedModule.set(module.name))
        ),
        Dynamic(App, selectedModule, moduleComponents, { styles: { xPos: "x30 ", yPos: "y460 ", wide: "w350 " } }),
        App.getCtrlByName(selectedModule.value . "Action").Opt("+Default")
    )
}