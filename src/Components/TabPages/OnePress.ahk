OnePress(App) {
    modules := [
        BlankShare(App),
        PaymentRelations(App),
        GroupShareDnm(App),
        Cashiering(App),
        PsbBatchUpload(App),
        BatchKeys(App),
    ]

    selectedModule := signal(modules[1].name)
    moduleComponents := Map()
    for module in modules {
        moduleComponents[module.name] := module
    }

    effect(selectedModule, moduleName => handleModuleChange(moduleName))
    handleModuleChange(moduleName){
        for module in modules {
            App.getCtrlByName(module.name . "Action").Opt(module.name = moduleName ? "+Default" : "-Default")
        }
        WinSetAlwaysOnTop (moduleName = "PaymentRelations"), popupTitle
    }

    return (
        modules.map(module =>
            App.AddRadio(A_Index = 1 ? "Checked x30 y+10 h20" : "x30 y+10 h20", module.description)
               .OnEvent("Click", (*) => selectedModule.set(module.name))
        ),
        Dynamic(selectedModule, moduleComponents),
        App.getCtrlByName(selectedModule.value . "Action").Opt("+Default")
    )
}