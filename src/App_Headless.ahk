#Include features\index.ahk

App_Headless(propString) {
    props := JSON.parse(propString)

    runRevenueReports(props)

    utils.cleanReload(WIN_GROUP, true)
}

runRevenueReports(props) {
    p := useProps(props, {
        date: A_Now.yesterday().toFormat("yyyyMMdd"),
        recipient: "cpxt5234@agent.qq.com",
        cc: ["shinwu@whiteswanhotel.com"],
        savepath: A_MyDocuments
    })

    msgbox JSON.stringify(p.toObject())

    BROWSER := FileExist("F:\360\360se6\Application\360se.exe")
        ? "F:\360\360se6\Application\360se.exe"
        : A_AppData . "\360se6\Application\360se.exe"
    PMS_URL := CONFIG.read(["pms", "url"])
    PMS_USERNAME := CONFIG.read(["pms", "username"])
    PMS_PASSWORD := CONFIG.read(["pms", "password"])

    fmtDate := p.date.toFormat("yyyy.MM.dd")

    reportDescriptors := [
        {
            searchStr: "RS05",
            saveFn: ReportMaster_Action.hisForSixMonths,
            filetype: "XML"            
        },
        {
            name: "RS07 MKT " fmtDate,
            searchStr: "RS07",
            saveFn: ReportMaster_Action.marketStats,
            args: ["MarketCode", p.date],
            filetype: "XML"
        },
        {
            name: "RS07 Source " fmtDate,
            searchStr: "RS07",
            saveFn: ReportMaster_Action.marketStats,
            args: ["SourceCode", p.date],
            filetype: "XML"
        },
        {
            name: "房型库存 " fmtDate,
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
        Sleep(Random(1000, 3000))

        savedReports.Push(A_MyDocuments "\" savedFiledName)
    }

    mailer := CurlMailer(
        CONFIG.read(["curl-mailer", "user"]),
        CONFIG.read(["curl-mailer", "auth"]),
        CONFIG.read(["curl-mailer", "url"])
    )

    result := mailer.Send(
        p.recipient,
        fmtDate "经营数据",
        "Please check the attachments.",
        [savedReports*],
        p.cc
    )

    if (p.savepath != A_MyDocuments) {
        for (report in savedReports) {
            FileMove(report, report.replace(A_MyDocuments, p.savepath), true)
        }
    }

    if (result.ok) {
        MsgBox("报表已发送。", POPUP_TITLE, "4096 T1 iconi")
    }
    else {
        MsgBox("发送失败`nExit code: " result.exitCode "`n" result.stderr, POPUP_TITLE, "4096 icon!")
    }
}