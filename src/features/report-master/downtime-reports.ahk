#SingleInstance Force
#Include ..\..\..\lib\lib-index.ahk
#Include report-master-action.ahk

if (A_ScriptName == "downtime-reports.ahk") {
    ; acquire admin
    if (!A_IsAdmin) {
        try {
            Run("*RunAs " . A_ScriptFullPath)
        }
        catch {
            ExitApp()
        }
    }

    POPUP_TITLE := "DownTime Reports"
    IMAGES := useImages("..\..\..\assets")
    TraySetIcon("..\..\..\assets\QMTray.ico")

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
 * @param {true | false} runAsIndividual
 */
DownTimeReports(App, runAsIndividual) {
    BROWSER := FileExist("F:\360\360se6\Application\360se.exe")
        ? "F:\360\360se6\Application\360se.exe"
        : A_AppData . "\360se6\Application\360se.exe"
    PMS_URL := "https://wsh-opr-app1"
    PMS_USERNAME := "FOHARALDC"
    PMS_PASSWORD := "sxzc123456"
    DOWNTIME_FOLDER := "\\10.0.2.13\fd\1-Reports\DownTime Reports"

    if (runAsIndividual) {
        closeCountdown := signal(30)
        SetTimer(cd(*) => closeCountdown.set(t => t - 1), 1000)
        effect(closeCountdown, cur => cur == 0 && handleSaveReports())
    }

    downtimeReportList := signal(ReportMaster_Action.reportList.downtime)

    handleBrowserReopen() {
        ; close all pms win
        loop {
            if (WinExist("OPERA Full Service Edition")) {
                WinKill("OPERA Full Service Edition")
            }
            Sleep(200)
        } until (!WinExist("OPERA Full Service Edition"))

        Run(BROWSER . " " . PMS_URL)
        WinWait("OPERA Login")
        WinActivate("OPERA Login")
        Sleep(200)

        ; log into opera
        Send("{TEXT}" . PMS_USERNAME)
        Sleep(100)
        Send("{Tab}")
        Sleep(100)
        Send("{TEXT}" . PMS_PASSWORD)
        Sleep(100)
        loop 3 {
            Send("{Tab}")
            Sleep(100)
        }
        Send("{Enter}")
        utils.waitLoading(1000)

        loop {
            found := ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["pms-login.png"])
            if (found) {
                break
            }
            Sleep(500)
        }
        Click(x, y)

        ; wait for PMS app
        WinWait("OPERA PMS")
        WinActivate("OPERA PMS")
        utils.waitLoading(2000)

        ; wait for window standby
        loop {
            found := ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-logo.png"])
            if (found) {
                break
            }
            Sleep(500)
        }
    }

    App.gui.OnEvent("Close", handleExitApp)
    handleExitApp(*) => ExitApp()

    handleSaveReports(*) {
        SetTimer(cd, 0)

        ; reopen browser
        handleBrowserReopen()

        ; check/create downtime report dir
        if (!DirExist(DOWNTIME_FOLDER)) {
            DirCreate(DOWNTIME_FOLDER)
        }

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

        loop files (A_MyDocuments . "\*.PDF") {
            if (downtimeReportList.value.find(reportObj => (A_LoopFileName.replace(".PDF") == reportObj.name))) {
                FileCopy(A_LoopFileFullPath, DOWNTIME_FOLDER . "\" . A_LoopFileName, true)
            }
        }

        saveText := "已保存报表：`n`n" . savedReports . "`n`n是否打开所在文件夹? "
        if (MsgBox(saveText, POPUP_TITLE, "OKCancel 4096 T5") == "OK") {
            Run(DOWNTIME_FOLDER)
        }

        if (runAsIndividual) {
            handleExitApp()
        }
    }

    handleAddButtons() {
        if (runAsIndividual) {
            App.AddButton("xs175 y+10 w80 h25", "取  消").onClick(handleExitApp),
                App.AddButton("x+10 w80 h25", "开始保存 ({1})", closeCountdown).onClick(handleSaveReports)
        }
        else {
            App.AddButton("xs265 y+10 w80 h25", "开始保存").onClick(handleSaveReports)
        }
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