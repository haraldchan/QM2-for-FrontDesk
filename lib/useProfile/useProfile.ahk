class useProfile {
    __New() {
        this.isUsing := true
        this.userFolder := A_ScriptDir . "\lib\useProfile\users"
        this.winMap := Map(
            "ahk_class SunAwtFrame", "opera",
            "ahk_exe vision.exe", "vingcard",
            "ahk_class 360se6_Frame", "psb"
        )
        
        this.users := []
        loop files this.userFolder . "\*.json" {
            this.users.Push(JSON.parse(FileRead(A_LoopFileFullPath, "UTF-8")))
        }
        this.curUser := this.users.find(user => user["username"] == "guest")
        
        this.prevHotstring := ""
        this.hotString := ""
        this.setHotString(this.hotString)
    }

    sendPassword() {
        for win, acc in this.winMap {
            if (WinActive(win)) {
                Send "{Text}" . Format("{1}`t{2}",
                    this.curUser["accounts"][acc]["username"],
                    this.curUser["accounts"][acc]["password"]
                )
            }
        }
    }

    setHotString(newStr) {
        this.prevHotstring := this.hotString
        this.hotString := newStr
        HotIf((*) => this.isUsing == true),
        Hotstring(this.prevHotString, (*) => this.sendPassword(), "Off")
        Hotstring(this.hotString, (*) => this.sendPassword(), "On")
    }

    setUser(username) {
        validateUser := this.users.find(user => user["username"] == StrLower(username))

        if (validateUser == "") {
            MsgBox("未找到对应用户",, "4096 T1")
            return
        }

        if (validateUser["username"] == "guest") {
            this.curUser := validateUser
            this.setHotString(this.curUser["hotString"])
            return
        }
        
        validation := InputBox("请输入主密码：")
        if (validation.Result == "Cancel") {
            return
        } else if (validation.Value != validateUser["password"]) {
            MsgBox("主密码错误",, "4096T1")
            return
        }
        
        this.curUser := validateUser
        this.setHotString(this.curUser["hotString"])
    }

    setUsing(state) {
        checkType(state, [Integer, Func])

        this.isUsing := state is Func ? state(this.isUsing) : state
        this.setUser(this.isUsing == false ? "guest" : this.curUser)
    }

    showUserInfo(App, formStatus := 0){
        App.getCtrlByName("showUserInfo").Enabled := false
        App.getCtrlByName("submitUserInfo").Enabled := false

        if (formStatus == "new") {
            this.setUser("guest")
        }

        UserInfo := Gui("+AlwaysOnTop", "用户信息")
        UserInfo.SetFont(, "微软雅黑")
        UserInfo.OnEvent("Close", guiObj => guiObj.Destroy())

        textStyle := "xs10 yp+30 w100 h25 0x200 "
        editStyle := "w200 x+10 h25 0x200 "

        handleNewForm() {
            for ctrl in UserInfo {
                if (ctrl is Gui.Edit) {
                    ctrl.Value := ""
                }
            }
        }

        handleSubmit() {
            formData := UserInfo.Submit()
            userData := {
                username: formData.masterUsername,
                password: formData.masterPassword,
                hotString: "::" . formData.hotstring,
                accounts: {
                    opera: {
                        username: formData.operaUsername,
                        password: formData.operaPassword,
                    },
                    vingcard: {
                        password: formData.vingcardPassword
                    },
                    psb: {
                        username: formData.psbUsername,
                        password: formData.psbPassword
                    }
                }
            }
            
            if (this.users.find(user => user["username"] == StrLower(userData.username)) == "") {
                this.users.Push(userData)
                App.getCtrlByType("ComboBox").Add([userData.username])

                FileAppend(JSON.stringify(userData), this.userFolder . "\" . userData.masterUsername . ".json", "UTF-8")
            } else {
                index := this.users.findIndex(user => user["username"] == StrLower(userData.username))
                this.users[index] := userData

                loop files this.userFolder . "*.json" {
                    FileDelete(userData.masterUsername . ".json")
                    FileAppend(JSON.stringify(userData), this.userFolder . "\" . userData.masterUsername . ".json", "UTF-8")
                }
                
            }

            App.getCtrlByName("showUserInfo").Enabled := true
            App.getCtrlByName("submitUserInfo").Enabled := true
            UserInfo.Destroy()
        }

        return (
            UserInfo.AddText("w100", "当前用户: "),
            UserInfo.AddEdit("w100 x+10 vmasterUsername", this.curUser["username"]),
            UserInfo.AddText("w100", "主密码: "),
            UserInfo.AddEdit("w100 x+10 vmasterPassword", this.curUser["password"]),
            UserInfo.AddText("w100", "输入指令: "),
            UserInfo.AddEdit("w100 x+10 vhotstring", this.curUser["hotstring"]),
            
            ; opera
            UserInfo.AddGroupBox("Section r2", "Opera PMS").SetFont("Bold"),
            UserInfo.AddText(textStyle, "账号: "),
            UserInfo.AddText(editStyle . "voperaUsername", this.curUser["accounts"]["opera"]["username"]),
            UserInfo.AddText(textStyle, "密码: "),
            UserInfo.AddText(editStyle . "voperaPassword", this.curUser["accounts"]["opera"]["password"]),
            
            ; psb
            UserInfo.AddGroupBox("Section r2", "旅业信息系统").SetFont("Bold"),
            UserInfo.AddText(textStyle, "账号: "),
            UserInfo.AddText(editStyle . "vpsbUsername", this.curUser["accounts"]["psb"]["username"]),
            UserInfo.AddText(textStyle, "密码: "),
            UserInfo.AddText(editStyle . "vpsbPassword", this.curUser["accounts"]["psb"]["password"]),

            ; vingcard
            UserInfo.AddGroupBox("Section r3", "VingCard").SetFont("Bold"),
            UserInfo.AddText(textStyle, "密码: "),
            UserInfo.AddText(editStyle . "vvingcardPassword", this.curUser["accounts"]["vingcard"]["password"]),

            ; btns
            UserInfo.AddButton("w60 h30", "新 建").OnEvent("Click", (*) => handleNewForm()),
            UserInfo.AddButton("w60 h30 x+10", "提 交").OnEvent("Click", (*) => handleSubmit()),

            UserInfo.Show()
        )
    }
}