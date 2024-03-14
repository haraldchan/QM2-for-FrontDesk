OnePress(QM, curSelectedScriptTab1) {
    modules := [
        InhShare,
        Pbpf,
        GroupShare,
        DoNotMove,
        ReportMaster,
        ; CashieringScripts
    ]

    radioStyle(index) {
        return index = 1 ? "Checked h25" : "h25 y+10"
    }

    ReportMasterNotifier := "
    (
        Report Master 常见问题：


        因报表保存过程中出现弹窗可能会导致中断，建议：

        1、 使用 IE 浏览器进行操作；

        2、 将登陆页面最小化；

        3、 重启浏览器以及 QM 2
    )"

    return (
        modules.map(module =>
            QM.AddRadio(radioStyle(A_Index), module.description)
                .OnEvent("Click", (*) => curSelectedScriptTab1.set(module))
        ),
        QM.AddText("y+35", ReportMasterNotifier)
    )
}