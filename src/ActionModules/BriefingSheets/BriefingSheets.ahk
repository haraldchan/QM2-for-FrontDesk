#Include "./BriefingSheets_Action.ahk"
#Include "./BriefingSheets_ReportList.ahk"
#Include "./BriefingSheets_Data.ahk"

BriefingSheets(props) {
    App := props.App

    bs := Component(App, A_ThisFunc)

    s := useProps(props.styles, {
        xPos: "x30 ",
        yPos: "y460 ",
        wide: "w350 "
    })

    action(*) {
        form := bs.submit()
        BriefingSheets_Action.USE(form)
    }

    bs.render := this => this.Add(
        App.AddGroupBox("Section r4 " . s.xPos . s.yPos . s.wide, "生成空白(NRR) Share"),

        ; Sheets
        App.AddCheckBox("vodg Checked xs10 w200", "生成 On-Day Group Details"),
        App.AddCheckBox("vsbl Checked xs10 w200", "生成 Shift Briefing Log"),

        ; action btn
        App.AddButton("vBriefingSheetsAction xs10 y+10 w100", "生成报表").OnEvent("Click", action)
    )

    return bs
}