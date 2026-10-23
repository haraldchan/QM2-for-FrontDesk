#Include fetch-fedex-resv-action.ahk
#Include fedex-signin-gen.ahk
#Include fedex-signin-gen-xl.ahk

/**
 * @param {Svaner} App 
 * @param {Object} [props] 
 * @returns {Component} 
 */
FetchFedexResv(App, props) {
    comp := Component(App, A_ThisFunc)

    action(*) {
        roomNum := App["room-num"]
        confNum := App["conf-num"]

        FetchFedexResv_Action.USE(roomNum.Value, confNum.Value)
        roomNum.Value := ""
        confNum.Value := ""

        roomNum.Focus()

        if (WinExist("ahk_class XLMAIN")) {
            WinActivate("ahk_class XLMAIN")
        }
    }

    handleFedexSignInGenerate(*) {
        ; FedexSignInGen_Xl.USE(
        FedexSignInGen.USE(
            FormatTime(A_Now, "yyyyMMdd"),
            App["fr-time"].Value,
            App["to-time"].Value
        )
    }

    handleSaveArrivalXml(*) {
        FedexSignInGen.saveArrivalXml(App["fr-time"].Value, App["to-time"].Value)
    }

    handleSigninTemplatePathUpdate(*) {
        App.Opt("+OwnDialogs")
        selectedFile := FileSelect(3, , "请选择 SignIn Sheet 模板文件", "Excel files(*.xls; *.xlsx; *.xlsm)")
        if (!selectedFile) {
            MsgBox("请选择文件")
            return
        }
        CONFIG.write(["fetch-fedex-resv", "template"], selectedFile)

        App["signin-template"].Value := selectedFile
        FedexSignInGen.signInTemplate := selectedFile
    }

    onMount() {
        FedexSignInGen.signInTemplate := CONFIG.read(["fetch-fedex-resv", "template"])
    }

    comp.render := (this) => this.Add(
        StackBox(
            App, 
            {
                font: { options: "bold" },
                groupbox: {
                    title: "FedEx Sign-In 生成",
                    options: "Section h100 @use:box"
                }
            },
            () => [
                App.AddText("@use:form-text", "时间范围"),
                App.AddEdit("@use:form-edit vfr-time w40", "00:00"),
                App.AddText("x+1 h25 0x200", " 至 "),
                App.AddEdit("@use:form-edit vto-time x+1 w40", "23:59"),
                App.AddButton("vsave-fdx-arr x+10 w100 h25", "保存团单")
                   .onClick(handleSaveArrivalXml),
                App.AddEdit("vsignin-template xs10 yp+30 w184 h25 ReadOnly", CONFIG.read(["fetch-fedex-resv", "template"])),
                App.AddButton("x+0 w28 h28", "🗃️")
                   .onClick(handleSigninTemplatePathUpdate),
                App.AddButton("x+10 w100 ", "生成 Sign-In 表")
                   .onClick(handleFedexSignInGenerate)
            ]
        ),
        StackBox(App, 
            {
                font: { options: "bold" },
                groupbox: {
                    title: "FedEx 订单信息抓取",
                    options: "Section h140 @use:box y+10"
                }
            },
            () => [
                App.AddText("@use:form-text yp+25", "预分房号"),
                App.AddEdit("vroom-num @use:form-edit"),
                App.AddText("@use:form-text", "确认号"),
                App.AddEdit("vconf-num @use:form-edit"),
                App.AddButton("vfetch-fedex-resv-action xs10 y+20 w100 ", "抓取订单信息").onClick(action)
            ]
        ),
        onMount()
    )

    return comp
}