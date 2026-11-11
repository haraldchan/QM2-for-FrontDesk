#Include features\index.ahk

App_Headless() {
    runRevenueReports()
}

runRevenueReports() {
    BROWSER := FileExist("F:\360\360se6\Application\360se.exe")
        ? "F:\360\360se6\Application\360se.exe"
        : A_AppData . "\360se6\Application\360se.exe"
    PMS_URL := CONFIG.read(["pms", "url"])
    PMS_USERNAME := CONFIG.read(["pms", "username"])
    PMS_PASSWORD := CONFIG.read(["pms", "password"])

    mailer := CurlMailer(
        CONFIG.read(["curl-mailer", "user"]),
        CONFIG.read(["curl-mailer", "auth"]),
        CONFIG.read(["curl-mailer", "url"])
    )

    reportDescriptors := [
        {
            name: "Market Segment by MarketCode @" FormatTime(A_Now, "yyyyMMdd HH:mm"),
            searchStr: "RS07",
            saveFn: ReportMaster_Action.marketStats,
            args: ["MarketCode", FormatTime(A_Now, "yyyyMMdd")],
            filetype: "PDF"
        },
        {
            name: "Market Segment by SourceCode @" FormatTime(A_Now, "yyyyMMdd HH:mm"),
            searchStr: "RS07",
            saveFn: ReportMaster_Action.marketStats,
            args: ["MarketCode", FormatTime(A_Now, "yyyyMMdd")],
            filetype: "PDF"
        },
        {
            name: "可售房型余量",
            searchStr: "detail_avail",
            saveFn: ReportMaster_Action.detailedAvailability,
            filetype: "XML"
        },
    ]

    ReportMaster_Action.handleBrowserReopen(BROWSER, PMS_URL, PMS_USERNAME, PMS_PASSWORD)

    savedReports := []
    for (descriptor in reportDescriptors) {
        ReportMaster_Action.start()
        savedFiledName := ReportMaster_Action.reportFiling(descriptor, descriptor.filetype)
        ReportMaster_Action.end()

        savedReports.Push(A_MyDocuments "\" savedFiledName)
    }

    result := mailer.Send(
        "shinwu@whiteswanhotel.com",
        "Reports @" FormatTime(A_Now, "yyyy-MM-dd HH:mm"),
        "Please check the attachments.",
        [savedReports*],
        ["cpxt5234@agent.qq.com"]
    )

    ; if (result.ok) {
    ;     MsgBox("报表已发送。", POPUP_TITLE, "4096 T1 iconi")
    ; }
    ; else {
    ;     MsgBox("发送失败`nExit code: " result.exitCode "`n" result.stderr, POPUP_TITLE, "4096 icon!")
    ; }
}

App_Headless()