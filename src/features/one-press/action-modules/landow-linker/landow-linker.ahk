#Include landow-linker-action.ahk

/**
 * @param {Svaner} App
 */
LandowLinker(App) {
    orderTypesRead := JSON.parse(
        FileRead(A_LineFile.replace(A_LineFile.split("\").at(-1), "order-types.json"), "utf-8")
    ).unshift("(请选择工单内容)")

    orderTypes := signal(orderTypesRead)

    App.defineDirectives(
        "@use:ll-text", "xs10 yp+30 w50 h20 0x200",
        "@use:ll-edit", "x+10 w150 h20 "
    )

    handleOrderTypeAutoComplete(ctrl, _) {
        if (!ctrl.Text) {
            orderTypes.reset()
            return
        }

        matchedList := orderTypesRead.filter(orderType => orderType.includes(ctrl.Text.toUpper()))
        if (!matchedList.Length) {
            orderTypes.reset()
            return
        }
        else {
            orderTypes.set(matchedList)
        }

        for (orderType in orderTypes.value) {
            if (orderType.includes(ctrl.Text.toUpper())) {
                ctrl.Text := orderType
                ctrl.Focus()
                if (!ctrl.Text) {
                    return
                }

                if (orderTypes.value.Length > 1) {
                    ControlShowDropDown(ctrl)
                }
                break
            }
        }
    }

    handleSendServiceOrder(*) {
        orderType := App["order-type"].Text
        qty := App["order-qty"].Text
        remark := App["order-remark"].Text

        if (!orderType) {
            MsgBox("工单内容不可为空", POPUP_TITLE, "4096 T1 icon!")
            return
        }

        LandowLinker_Action.sendServiceOrder(orderType, qty, remark)
    }

    handleSendRoomMove(*) {
        newRoomNum := App["new-room-num"].Text
        prevRoomStatus := App["prev-room-status"].Text
        roomMoveReason := App["room-move-reason"].Text

        if (!newRoomNum) {
            MsgBox("新房号不可为空", POPUP_TITLE, "4096 T1 icon!")
            return
        }

        if (!roomMoveReason) {
            MsgBox("换房原因不可为空", POPUP_TITLE, "4096 T1 icon!")
            return
        }

        

        LandowLinker_Action.sendRoomMove(newRoomNum, roomMoveReason, prevRoomStatus)
    }

    render() {
        StackBox(
            App, {
                font: { options: "bold" },
                groupbox: {
                    title: "物品/服务工单",
                    options: "Section x30 y+10 w350 h130"
                }
            },
            () => [
                App.AddText("vservice-order-line1 @use:ll-text", "工单内容"),
                App.AddComboBox("vorder-type x+10 w150 Choose1", orderTypes).onChange(handleOrderTypeAutoComplete, 300),
                ;
                App.AddText("@use:ll-text", "数量"),
                App.AddEdit("vorder-qty @use:ll-edit Number", "1"),
                ;
                App.AddText("@use:ll-text", "备注(可选)"),
                App.AddEdit("vorder-remark @use:ll-edit ", ""),
                ;
                App.AddButton("@relative[x+180]:service-order-line1 @align[y]:service-order-line1 w90 h30", "发送工单")
                   .onClick(handleSendServiceOrder)
            ]
        )
        StackBox(
            App, {
                font: { options: "bold" },
                groupbox: {
                    title: "在住客人换房",
                    options: "Section x30 y+10 w350 h180"
                }
            },
            () => [
                App.AddText("vroommove-line1 @use:ll-text", "新房号"),
                App.AddEdit("vnew-room-num @use:ll-edit", ""),
                ; 
                App.AddText("@use:ll-text", "旧房房态"),
                App.AddDDL("vprev-room-status x+10 w150 Choose1", ["Dirty", "Inspected"]),
                ; 
                App.AddText("@use:ll-text", "换房原因"),
                App.AddEdit("vroom-move-reason @use:ll-edit h60", ""),
                ; 
                App.AddButton("@relative[x+180]:roommove-line1 @align[y]:roommove-line1 w90 h30", "执行换房")
                   .onClick(handleSendRoomMove)
            ]
        )
    }

    return render()
}
