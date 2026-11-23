;utils: general utility methods
class utils {
    /**
     * Reset windows and key states.
     * @param {Array} winGroup Windows to release.
     * @param {true | false} quit Exit app on reload.
     */
    static cleanReload(winGroup, quit := 0) {
        ; Windows set default
        loop winGroup.Length {
            if (WinExist(winGroup[A_Index])) {
                WinSetAlwaysOnTop(false, winGroup[A_Index])
            }
        }
        ; Key/Mouse state set default
        BlockInput(false)
        SetCapsLockState(false)
        CoordMode("Mouse", "Screen")
        ; remove qr creator temp file
        if (FileExist(A_Temp "\qr-creator-temp.png")) {
            FileDelete(A_Temp "\qr-creator-temp.png")
        }

        quit ? ExitApp() : Reload()
    }

    /**
     * 
     * @param {String} appName 
     * @param {String} popupTitle 
     * @param {Array} winGroup 
     */
    static quitApp(appName, popupTitle, winGroup) {
        quitConfirm := MsgBox(Format("是否退出 {1}？", appName), popupTitle, "OKCancel 4096")
        quitConfirm = "OK" ? this.cleanReload(winGroup, true) : this.cleanReload(winGroup)
    }

    /**
     * 
     * @param {Integer} interval waiting interval in ms.
     */
    static waitLoading(interval := 250) {
        loop {
            sleep(interval)
            if (A_Cursor != "Wait") {
                break
            }
        }
    }

    static clearExistInstances() {
        DetectHiddenWindows(true)
        existInstances := WinGetList(A_ScriptName)
        if (existInstances.Length > 0) {
            for instanceID in existInstances {
                if (instanceID != A_ScriptHwnd) {
                    WinKill(instanceID)
                }
            }
        }

    }

    static killApp(exe) {
        loop {
            if (id := WinExist("ahk_exe" . exe)) {
                pid := WinGetPID("ahk_id " . id)
                if (!pid) {
                    break
                }
                ProcessClose(pid)
            }
        } until (!WinExist(exe))
    }

    static URIEncode(Url, Flags := 0x000C3000) {
        Local CC := 4096, Esc := "", Result := ""
        Loop {
            VarSetStrCapacity(&Esc, CC), Result := DllCall("Shlwapi.dll\UrlEscapeW", "Str", Url, "Str", &Esc, "UIntP", &CC, "UInt", Flags, "UInt")
        } Until Result != 0x80004003 ; E_POINTER
        Return Esc
    }

    static newGuid() {
        guid := Buffer(16)
        DllCall("ole32\CoCreateGuid", "Ptr", guid)

        str := Buffer(78)
        DllCall("ole32\StringFromGUID2", "Ptr", guid, "Ptr", str, "Int", 39)

        return Trim(StrGet(str, "UTF-16"), "{}")
    }


    class Hash {
        static md5(str, encoding := "UTF-8") {
            static ALG_HANDLE := 0
            static OBJ_LENGTH := 0
            static HASH_LENGTH := 16

            if !ALG_HANDLE {
                DllCall("bcrypt\BCryptOpenAlgorithmProvider",
                    "Ptr*", &ALG_HANDLE := 0,
                    "WStr", "MD5",
                    "Ptr", 0,
                    "UInt", 0)

                DllCall("bcrypt\BCryptGetProperty",
                    "Ptr", ALG_HANDLE,
                    "WStr", "ObjectLength",
                    "UInt*", &OBJ_LENGTH := 0,
                    "UInt", 4,
                    "UInt*", &result := 0,
                    "UInt", 0)
            }

            hashObject := Buffer(OBJ_LENGTH)
            hashBuffer := Buffer(HASH_LENGTH)

            DllCall("bcrypt\BCryptCreateHash",
                "Ptr", ALG_HANDLE,
                "Ptr*", &hashHandle := 0,
                "Ptr", hashObject,
                "UInt", hashObject.Size,
                "Ptr", 0,
                "UInt", 0,
                "UInt", 0)

            data := Buffer(StrPut(str, encoding) - (encoding = "UTF-16" ? 1 : 1))
            StrPut(str, data, encoding)

            DllCall("bcrypt\BCryptHashData",
                "Ptr", hashHandle,
                "Ptr", data,
                "UInt", data.Size - (encoding = "UTF-16" ? 2 : 1),
                "UInt", 0)

            DllCall("bcrypt\BCryptFinishHash",
                "Ptr", hashHandle,
                "Ptr", hashBuffer,
                "UInt", hashBuffer.Size,
                "UInt", 0)

            DllCall("bcrypt\BCryptDestroyHash", "Ptr", hashHandle)

            hash := ""
            Loop hashBuffer.Size
                hash .= Format("{:02x}", NumGet(hashBuffer, A_Index - 1, "UChar"))

            return hash
        }
    }
}