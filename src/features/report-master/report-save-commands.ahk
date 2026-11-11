#SingleInstance Off
#Include ..\..\..\lib\lib-index.ahk
#Include report-master-action.ahk

POPUP_TITLE := "Reports"

reportList := [{
    searchStr: "rs07",
    name: "RS07-MarketSegment",
    saveFn: ReportMaster_Action.marketStats,
    args: ["MarketCode"]
}, {
    searchStr: "rs07",
    name: "RS07-SourceSegment",
    saveFn: ReportMaster_Action.marketStats,
    args: ["SourceCode"]
}, {
    searchStr: "rs05",
    name: "RS05-未来六月",
    saveFn: ReportMaster_Action.hisForSixMonths
}
]

saveReports(whichReport, fileFormat) {
    reportDescriptors := []

    switch whichReport {
        case "market":
            reportDescriptors.Push(reportList[1])
        case "source":
            reportDescriptors.Push(reportList[2])
        case "rs05":
            reportDescriptors.Push(reportList[3])
        default:
            reportDescriptors := reportList
    }

    ; ReportMaster_Action.saveReports(reportDescriptors, A_Args[2])
    MsgBox(
        Format("desciptor:`n {}`n`nFile format: {}", JSON.stringify(reportDescriptors), fileFormat)
    )
}

; saveReports(A_Args[1], A_Args.Has(2) ? A_Args[2] : "PDF")

; run with:
; [System.Diagnostics.Process]::Start("<ahk path in ProgramFiles>", "<report-save-commands.ahk path> <which report> <file format>")
