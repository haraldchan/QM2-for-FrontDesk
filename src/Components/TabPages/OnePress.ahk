OnePress(App) {
    styles := {
        pos: "x30 y420"
    }

    modules := [
        BlankShare(App, styles),
        PaymentRelation(App, styles),
        GroupShareDnm(App, styles),
        Cashiering(App, styles),
        PsbBatchUpload(App, styles),
        BatchKeys(App, styles),
        FetchFedexResv(App, styles)
    ]

    selectedModule := signal(modules[1].name)
    moduleComponents := OrderedMap()
    for module in modules {
        moduleComponents[module.name] := module
    }

    effect(selectedModule, moduleName => handleModuleChange(moduleName))
    handleModuleChange(moduleName){
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
        Dynamic(selectedModule, moduleComponents),
        App.getCtrlByName(selectedModule.value . "Action").Opt("+Default")
    )
}
