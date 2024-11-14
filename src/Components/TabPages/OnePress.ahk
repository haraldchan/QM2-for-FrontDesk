OnePress(App) {
    modules := [
        BlankShare,
        PaymentRelation,
        GroupShareDnm,
        Cashiering,
        PsbBatchUpload,
        BatchKeys,
        FetchFedexResv
    ]

    selectedModule := signal(modules[1].name)
    moduleComponents := OrderedMap()
    for module in modules {
        moduleComponents[module.name] := module
    }

    effect(selectedModule, moduleName => handleModuleChange(moduleName))
    handleModuleChange(moduleName) {
        for module in modules {
            App.getCtrlByName(module.name . "Action").Opt(module.name = moduleName ? "+Default" : "-Default")
        }
        WinSetAlwaysOnTop (moduleName = "PaymentRelation"), popupTitle
    }

    return (
        modules.map(module =>
            App.AddRadio(A_Index = 1 ? "Checked x30 y+10 h20" : "x30 y+10 h20", module.description)
            .OnEvent("Click", (*) => selectedModule.set(module.name))
        ),
        Dynamic(selectedModule, moduleComponents, { App: App, styles: { xPos: "x30 ", yPos: "420 ", wide: "350 " } }),
        App.getCtrlByName(selectedModule.value . "Action").Opt("+Default")
    )
}