;utils: general utility methods
class utils {
    ; Reset windows and key states.
    static cleanReload(winGroup, quit := 0) {
        ; Windows set default
        loop winGroup.Length {
            if (WinExist(winGroup[A_Index])) {
                WinSetAlwaysOnTop false, winGroup[A_Index]
            }
        }
        ; Key/Mouse state set default
        BlockInput false
        SetCapsLockState false
        CoordMode "Mouse", "Screen"
        if (quit = "quit") {
            ExitApp
        }
        Reload
    }

    ; Exit app with clean reload.
    static quitApp(appName, popupTitle, winGroup) {
        quitConfirm := MsgBox(Format("是否退出 {1}？", appName), popupTitle, "OKCancel 4096")
        quitConfirm = "OK" ? this.cleanReload(winGroup, "quit") : this.cleanReload(winGroup)
    }

    ; Insert text at the beginning of file.
    static filePrepend(textToInsert, fileToPrepend) {
        textOrigin := FileRead(fileToPrepend)
        FileDelete fileToPrepend
        FileAppend textToInsert . textOrigin, fileToPrepend
    }

    ; Type checking with error msg.
    static checkType(val, typeChecking, errMsg) {
        if (!(val is typeChecking)) {
            throw TypeError(Format("{1}; `n`nCurrent Type: {2}", errMsg, Type(val)))
        }
    }

    static imgSearchAll(imgPath, method := "TD") {
        ; method: "LeftRight" or "LR", "TopDown" or "TD"
        target := imgPath
        coords := []
        fromWidth := 0
        fromHeight := 0

        loop {
            if (!ImageSearch(&FoundX, &FoundY, fromWidth, fromHeight, A_ScreenWidth, A_ScreenWidth, target)) {
                if (A_Index = 1) {
                    MsgBox("Image Not Found.")
                }
                break
            } else {
                x := FoundX
                y := FoundY
                coords.Push([x, y])

                if (method = "LeftRight" || method = "LR") {
                    fromWidth := x
                } else if (method = "TopDown" || method = "TD") {
                    fromHeight := y
                }
            }
        }
    }

    static waitLoading(interval := 250) {
        loop {
            sleep interval
            if (A_Cursor != "Wait") {
                break
            }
        }
    }
}

; jsa: array methods that mimic JavaScript's Array.Prototype methods.
; class jsa {
;     static some(fn, targetArray) {
;         utils.checkType(fn, Func, "First parameter is not a Function Object.")
;         utils.checkType(targetArray, Array, "Second parameter is not an Array")

;         loop targetArray.Length {
;             if (fn(targetArray[A_Index])) {
;                 return true
;             }
;         }
;         return false
;     }

;     static every(fn, targetArray) {
;         utils.checkType(fn, Func, "First parameter is not a Function Object.")
;         utils.checkType(targetArray, Array, "Second parameter is not an Array")

;         loop targetArray.Length {
;             if (!fn(targetArray[A_Index])) {
;                 return false
;             }
;         }
;         return true
;     }

;     static filter(fn, targetArray) {
;         utils.checkType(fn, Func, "First parameter is not a Function Object.")
;         utils.checkType(targetArray, Array, "Second parameter is not an Array")

;         newArray := []
;         loop targetArray.Length {
;             if (fn(targetArray[A_Index])) {
;                 newArray.Push(targetArray[A_Index])
;             }
;         }
;         return newArray
;     }

;     static map(fn, targetArray) {
;         utils.checkType(fn, Func, "First parameter is not a Function Object.")
;         utils.checkType(targetArray, Array, "Second parameter is not an Array")

;         newArray := []
;         loop targetArray.Length {
;             newArray.Push(fn(targetArray[A_Index]))
;         }
;         return newArray
;     }

;     static reduce(fn, targetArray, initialValue := 0) {
;         utils.checkType(fn, Func, "First parameter is not a Function Object.")
;         utils.checkType(targetArray, Array, "Second parameter is not an Array")
;         utils.checkType(initialValue, Number, "Third parameter is not an Number")

;         initIsSet := !(initialValue = 0)
;         accumulator := initIsSet ? initialValue : targetArray[1]
;         currentValue := initIsSet ? targetArray[1] : targetArray[2]
;         loopTimes := initIsSet ? targetArray.Length : targetArray.Length - 1
;         result := 0
;         loop loopTimes {
;             if (A_Index = 1) {
;                 result := fn(accumulator, currentValue)
;             } else {
;                 if (!(initialValue = 0)) {
;                     result := fn(result, targetArray[A_Index])
;                 } else {
;                     result := fn(result, targetArray[A_Index + 1])
;                 }
;             }
;         }
;         return result
;     }

;     static with(index, newValue, targetArray) {
;         if (index > targetArray.Length) {
;             throw ValueError("Index out of range")
;         }
;         utils.checkType(targetArray, Array, "Third parameter is not an Array")

;         newArray := []
;         loop targetArray.Length {
;             newArray.Push(targetArray[A_Index])
;         }
;         newArray[index] := newValue
;         return newArray
;     }
; }

; interface: methods to interact with GUI controls.
; class interface {
;     static getCtrlByName(vName, ctrlArray) {
;         utils.checkType(ctrlArray, Array, "Second parameter is not an Array")

;         for item in ctrlArray {
;             if (item is Array) {
;                 arrElement := item
;                 utils.checkType(arrElement, Gui.Control, "Item is not an GUI Contol")
;                 this.getCtrlByName(vName, arrElement)
;             }
;             utils.checkType(item, Gui.Control, "Item is not an GUI Contol")
;             if (vName = item.Name) {
;                 return item
;             }
;         }
;     }

;     static getCtrlByType(ctrlType, ctrlArray) {
;         utils.checkType(ctrlArray, Array, "Second parameter is not an Array")

;         for item in ctrlArray {
;             if (item is Array) {
;                 arrElement := item
;                 utils.checkType(arrElement, Gui.Control, Format("{1} is not an GUI Contol", arrElement))
;                 this.getCtrlByType(ctrlType, arrElement)
;             }
;             utils.checkType(item, Gui.Control, "Item is not an GUI Contol")
;             if (ctrlType = item.Type) {
;                 return item
;             }
;         }
;     }

;     static getCtrlByTypeAll(ctrlType, ctrlArray) {
;         utils.checkType(ctrlArray, Array, "Second parameter is not an Array")

;         controls := []

;         for item in ctrlArray {
;             utils.checkType(ctrlArray[A_Index], Gui.Control, "Item is not an GUI Contol")
;             if (ctrlType = item.Type) {
;                 controls.Push(item)
;             }
;         }

;         return controls
;     }

;     static getCheckedRowNumbers(listViewCtrl) {
;         if (!(listViewCtrl is Gui.Control) || listViewCtrl.Type != "ListView") {
;             throw TypeError("Parameter is not an ListView.")
;         }

;         checkedRowNumbers := []
;         loop listViewCtrl.GetCount() {
;             curRow := listViewCtrl.GetNext(A_Index - 1, "Checked")
;             try {
;                 if (curRow = prevRow || curRow = 0) {
;                     Continue
;                 }
;             }
;             checkedRowNumbers.Push(curRow)
;             prevRow := curRow
;         }
;         return checkedRowNumbers
;     }

;     static getCheckedRowDataMap(listViewCtrl, mapKeys, checkedRows) {
;         if (!(listViewCtrl is Gui.Control) || listViewCtrl.Type != "ListView") {
;             throw TypeError("Parameter is not an ListView.")
;         }
;         utils.checkType(mapKeys, Array, "Second parameter is not an Array")
;         utils.checkType(checkedRows, Array, "Third parameter is not an Array")

;         checkedRowsData := []
;         for rowNumber in checkedRows {
;             dataMap := Map()
;             for key in mapKeys {
;                 dataMap[key] := listViewCtrl.GetText(rowNumber, A_Index)
;             }
;             checkedRowsData.Push(dataMap)
;         }
;         return checkedRowsData
;     }
; }