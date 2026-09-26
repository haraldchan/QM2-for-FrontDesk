#Include landow-image-finder.ahk

class Landow {
    static appPath := "C:\Program Files (x86)\Landow\CmsManager\CmsManager.exe"
    static loginTitle := "登录"
    static mainWinTitle := "住客服务管家"
    static mainWinHwnd := this.getMainWinHwnd()
    static orderWinHwnd := ""

    static getMainWinHwnd() {
        ids := WinGetList("ahk_exe CmsManager.exe")
        for (id in ids) {
            if (WinGetTitle(id) == this.mainWinTitle) {
                return id
            }
        }
    }

    static runAndLogin() {
        Run(this.appPath)
        loop {
            if (WinExist(this.loginTitle)) {
                break
            }
            Sleep(100)

            if (A_Index > 100) {
                break
            }
        }

        WinActivate(this.loginTitle)
        Send("{Tab}")
        Sleep(100)
        Send("{Space}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)

        if (!WinWait(, this.mainWinTitle, 5)) {
            return
        }

        this.mainWinHwnd := this.getMainWinHwnd()

        WinActivate(this.mainWinHwnd)
        Sleep(100)

        CoordMode("Mouse", "Client")
        Click(65, 225)
        CoordMode("Mouse", "Screen")
    }

    static close() {
        if (WinExist(this.mainWinHwnd)) {
            ProcessClose(WinGetPID(this.mainWinHwnd))
        }
    }


    ; 对客服务
    static clickGuestService() {
        CoordMode("Mouse", "Window")
        ; click guest feedback as a reset
        Click(60, 90)
        Sleep(100)

        Click(60, 226)
        CoordMode("Mouse", "Screen")
    }

    ; 新建服务单
    static clickNewOrder() {
        CoordMode("Mouse", "Window")
        Click(201, 59)
        CoordMode("Mouse", "Screen")
    }

    ; 物品服务
    static clickItemAndService() {
        CoordMode("Mouse", "Window")
        Click(207, 140)
        CoordMode("Mouse", "Screen")

        Sleep(500)
        this.orderWinHwnd := WinGetList("ahk_exe CmsManager.exe").find(id => id != this.mainWinHwnd)
    }

    ; 客人换房
    static clickRoomMove() {
        CoordMode("Mouse", "Window")
        Click(299, 238)
        CoordMode("Mouse", "Screen")

        Sleep(500)
        this.orderWinHwnd := WinGetList("ahk_exe CmsManager.exe").find(id => id != this.mainWinHwnd)
    }

    /**
     * @param {String} roomNum
     * @param {String} orderType 
     * @param {Integer} qty 
     * @param {String} remarks 
     */
    static createOrder(roomNum, orderType, qty := 1, remarks := "") {
        if (!WinExist(this.mainWinTitle)) {
            this.runAndLogin()
        }

        this.mainWinHwnd := this.getMainWinHwnd()
        WinActivate(this.mainWinHwnd)

        ; clear exist modal
        landowWinIds := WinGetList("ahk_exe CmsManager.exe")
        for (id in landowWinIds) {
            if (id != this.mainWinHwnd) {
                try {
                    WinClose(id)
                }
            }
        }

        this.clickGuestService()
        Sleep(100)
        this.clickNewOrder()
        Sleep(100)
        this.clickItemAndService()
        Sleep(100)

        WinActivate(this.orderWinHwnd)

        found := LandowImageFinder.find("landow-no-guest.png", 50)
        if (!found) {
            throw Error("Landow CmsManager failed.")
        }

        ; send room num and wait for guest to load
        Sleep(200)
        Send("{Text}" . roomNum)
        Sleep(500)
        Send("{Enter}")
        Sleep(100)

        found := LandowImageFinder.find("landow-loaded.png", 50)
        if (!found) {
            this.close()
            throw Error("Landow CmsManager failed.")
        }

        ; send order type
        Sleep(200)
        Send("{Tab}")
        Sleep(100)
        Send("{Text}" . orderType)
        Sleep(100)
        Send("{Enter}")
        Sleep(500)

        ; send qty
        Send("{Tab}")
        Sleep(100)
        Send("{Text}" . qty)
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; move to remarks
        Send("{Tab}")
        Sleep(100)
        Send("{Text}" . remarks)

        ; confirm send
        Send("{Tab}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        ; TODO: resolve duplicated order

        this.orderWinHwnd := ""
    }

    static createRoomMove(curRoomNum, newRoomNum, reason) {
        if (!WinExist(this.mainWinTitle)) {
            this.runAndLogin()
        }

        this.mainWinHwnd := this.getMainWinHwnd()
        WinActivate(this.mainWinHwnd)

        ; clear exist modal
        landowWinIds := WinGetList("ahk_exe CmsManager.exe")
        for (id in landowWinIds) {
            if (id != this.mainWinHwnd) {
                try {
                    WinClose(id)
                }
            }
        }

        this.clickGuestService()
        Sleep(100)
        this.clickNewOrder()
        Sleep(100)
        this.clickRoomMove()
        Sleep(100)

        WinActivate(this.orderWinHwnd)

        found := LandowImageFinder.find("landow-no-guest.png", 50)
        if (!found) {
            throw Error("Landow CmsManager failed.")
        }

        ; send current room num
        CoordMode("Mouse", "Window")
        Click(found.outX - 410, found.outY - 32)
        Sleep(200)
        Send("{Text}" . curRoomNum)
        Sleep(500)
        Send("{Enter}")
        Sleep(200)

        ; wait for guest info to load
        guestLoaded := LandowImageFinder.find("landow-loaded.png", 50)
        if (!guestLoaded) {
            ; this.close()
            throw Error("Landow CmsManager failed.")
        }

        ; send new room num
        CoordMode("Mouse", "Window")
        Click(found.outX - 410, found.outY + 87)
        Sleep(200)
        Send("{Text}" . newRoomNum)
        Sleep(500)
        Send("{Enter}")
        Sleep(200)

        ; send remarks
        MouseGetPos(&curX, &curY)
        Click(curX, curY + 150)
        Sleep(200)
        Send("{Text}" . reason)
        Sleep(500)
        Send("{Enter}")
        Sleep(200)

        ; confirm send
        Send("{Tab}")
        Sleep(200)
        Send("{Enter}")
        Sleep(200)

        CoordMode("Mouse", "Screen")
        this.orderWinHwnd := ""
    }
}