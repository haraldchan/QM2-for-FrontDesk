#SingleInstance Off
#Include ..\..\..\lib\lib-index.ahk
#Include report-master-action.ahk

if (A_ScriptName == "downtime-reports.ahk") {
    ; acquire admin
    if (!A_IsAdmin) {
        Run("*RunAs " . A_ScriptFullPath)
        ExitApp()
    }

    ; close other instances
    utils.clearExistInstances()

    POPUP_TITLE := "DownTime Reports"
    CONFIG := useJsonConfig(
        "\\10.0.2.13\FD\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\QM2-for-FrontDesk-main\qm.config.json", 
        "qm.config.json",
        A_AppData . "\QM2"
    )

    IMAGES := useImages("..\..\..\assets")
    PmsImageFinder.images := IMAGES

    FORCE_SUSPEND_MESSAGE := 0x2042
    SUSPEND_CONTROLLER := SuspendController(FORCE_SUSPEND_MESSAGE)

    TraySetIcon(IMAGES["QMTray.ico"])

    DownTimeWin := Svaner({
        gui: {
            title: "DownTime Reports"
        },
        font: {
            name: "微软雅黑"
        },
    })

    DownTimeReports(DownTimeWin, true)
    DownTimeWin.Show()
}

/**
 * @param {Svaner} App 
 * @param {true | false} runAsInstance
 */
DownTimeReports(App, runAsInstance) {
    BROWSER := FileExist("F:\360\360se6\Application\360se.exe")
        ? "F:\360\360se6\Application\360se.exe"
        : A_AppData . "\360se6\Application\360se.exe"
    PMS_URL := CONFIG.read(["pms", "url"])
    PMS_USERNAME := CONFIG.read(["pms", "username"])
    PMS_PASSWORD := CONFIG.read(["pms", "password"])
    DOWNTIME_FOLDER := CONFIG.read(["report-master", "downtime-folder"])

    if (runAsInstance) {
        closeCountdown := signal(30)
        SetTimer(cd(*) => closeCountdown.set(t => t - 1), 1000)
        effect(closeCountdown, cur => cur == 0 && handleSaveReports())
    }

    downtimeReportList := signal(ReportMaster_Action.reportList.downtime)

    App.gui.OnEvent("Close", handleExitApp)
    handleExitApp(*) {
        if (runAsInstance) {
            SetTimer(cd, 0)
        }
        ExitApp()
    }

    handleSendEmail(reportPaths) {
        if (!reportPaths.Length) {
            return
        }

        config := JSON.parse(FileRead(A_AppData "\QM2\qm.config.json", "utf-8"))
        mailerInfo := config["curl-mailer"]

        mailer := CurlMailer(
            mailerInfo["user"],
            mailerInfo["auth"],
            mailerInfo["url"]
        )

        result := mailer.Send(
            "reception@whiteswanhotel.com",
            "DownTime Reports @" FormatTime(A_Now, "yyyy-MM-dd HH:mm"),
            "Please check the attachments.",
            [reportPaths*]
        )

        if (result.ok) {
            MsgBox("报表已发送。", POPUP_TITLE, "4096 T1 iconi")
        }
        else {
            MsgBox("发送失败`nExit code: " result.exitCode "`n" result.stderr, POPUP_TITLE, "4096 T2 icon!")
        }
    }

    handleSaveReports(*) {
        SetTimer(cd, 0)

        ; reopen browser
        ReportMaster_Action.handleBrowserReopen(BROWSER, PMS_URL, PMS_USERNAME, PMS_PASSWORD)

        ; check/create downtime report dir
        DirCreate(DOWNTIME_FOLDER)

        selectedReports := []
        selectedRows := App["downtime-list"].getCheckedRowNumbers()
        if (!selectedRows.Length) {
            MsgBox("未选中报表", POPUP_TITLE, "4096 T2 icon!")
            App.Show()
            return
        }

        for row in selectedRows {
            selectedReports.Push(downtimeReportList.value[row])
        }

        savedReports := ReportMaster_Action.saveReports(selectedReports, "PDF")

        reportsToSend := []

        loop files (A_MyDocuments . "\*.PDF") {
            if (downtimeReportList.value.find(reportObj => A_LoopFileName.includes(reportObj.name))) {
                FileCopy(A_LoopFileFullPath, DOWNTIME_FOLDER . "\" . A_LoopFileName, true)
                reportsToSend.Push(A_LoopFileFullPath)
            }
        }

        handleSendEmail(reportsToSend)

        saveText := "已保存报表：`n`n" . savedReports . "`n`n是否打开所在文件夹? "
        if (MsgBox(saveText, POPUP_TITLE, "OKCancel 4096 T5") == "OK") {
            Run(DOWNTIME_FOLDER)
        }

        if (runAsInstance) {
            handleExitApp()
        }
    }

    handleAddButtons() {
        return runAsInstance
            ? [
                App.AddButton("xs175 y+10 w80 h25", "取  消").onClick(handleExitApp),
                App.AddButton("x+10 w80 h25", "开始保存 ({1})", closeCountdown).onClick(handleSaveReports)
            ]
            : App.AddButton("xs265 y+10 w80 h25", "开始保存").onClick(handleSaveReports)
    }

    render() {
        StackBox(App, {
            groupbox: {
                title: "DownTime Report 保存",
                options: "Section w355 h430",
            },
            font: { options: "s10.5 bold" }
        },
            () => [
                App.AddText("xs10 yp+35 w330", Format("当前时间：{}", A_Now.toFormat("yyyy-MM-dd HH:mm"))),
                ; notes
                App.AddText("y+10 w330 h25", "注意事项").setFont("s10 bold"),
                App.AddText("xs10 y+1 w330", " - 启动后将重启浏览器，请先保存   未完成工作。"),
                ; report list
                App.AddText("y+15 w330 h25", "报表列表").setFont("s10 bold"),
                App.AddListView({
                    lvOptions: "vdowntime-list Checked Grid NoSortHdr -ReadOnly -Multi @lv:label-tip xs13 y+1 w330 r10",
                    itemOptions: "Check"
                }, {
                    keys: ["searchStr", "name"],
                    titles: ["搜索字段", "报表名称"],
                    widths: [120, 200]
                },
                    downtimeReportList
                ),
                handleAddButtons(),
            ]
        )
    }

    return render()
}
