/**
 * @param {Svaner} App 
 */
RevenueReports(App) {
    date := A_Now.yesterday().toFormat("yyyyMMdd")
    fmtDate := FormatTime(date, "yyyy.MM.dd")

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
            args: ["MarketCode", date],
            filetype: "XML"
        },
        {
            name: "RS07 Source " fmtDate,
            searchStr: "RS07",
            saveFn: ReportMaster_Action.marketStats,
            args: ["SourceCode", date],
            filetype: "XML"
        },
        {
            name: "房型库存 " fmtDate,
            searchStr: "detail_avail",
            saveFn: ReportMaster_Action.detailedAvailability,
            filetype: "XML"
        },
    ]

    mailer := CurlMailer(
        CONFIG.read(["curl-mailer", "user"]),
        CONFIG.read(["curl-mailer", "auth"]),
        CONFIG.read(["curl-mailer", "url"])
    )

    saveReports(*) {
        savedReports := []
        reportsToSend := []
        for (descriptor in reportDescriptors) {
            ; if (!descriptor.isSave) {
            ;     continue
            ; }

            ReportMaster_Action.start()
            savedFiledName := ReportMaster_Action.reportFiling(descriptor, descriptor.filetype)
            ReportMaster_Action.end()
            Sleep(Random(1000, 1500))
            if (!savedFiledName) {
                continue
            }

            savedReports.Push(A_MyDocuments "\" savedFiledName)
            ; if (descriptor.sendEmail) {
                reportsToSend.Push(A_MyDocuments "\" savedFiledName)
            ; }
        }

        result := mailer.Send(
            "cpxt5234@agent.qq.com",
            fmtDate "经营数据",
            "Please check the attachments.",
            [savedReports*],
            ["shinwu@whiteswanhotel.com"]
        )

        if (result.ok) {
            MsgBox("报表已发送。", POPUP_TITLE, "4096 T1 iconi")
        }
        else {
            MsgBox("发送失败`nExit code: " result.exitCode "`n" result.stderr, POPUP_TITLE, "4096 icon!")
        }
    }

    render() {
        StackBox(App, {
            groupbox: {
                title: "收益报表保存",
                options: "Section w355 h430",
            },
            font: { options: "s10.5 bold" }
        },
            () => [
                App.AddText("xs10 yp+35 w330", "完成保存并发送后，请查看邮箱已发送中是否有 收益报表 邮件"),
                App.AddButton("xs265 y+10 w80 h25", "开始保存").onClick(saveReports)
            ]
        )
    }

    return render()
}