class BriefingSheets_Action {
    static USE(form) {
        this.saveReports(form)

    }

    static saveReports(form) {
        ReportMasterNext_Action.start()
        for report in BriefingSheets_ReportList.reportList {
            if (!form.sbl && report.name.includes("Vip")) {
                continue
            }
            ReportMasterNext_Action.reportFiling(report, "XML")
        }
        ReportMasterNext_Action.end()
    }
}