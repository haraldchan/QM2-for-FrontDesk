#Include fetch-fedex-resv-action.ahk

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
            WinActivate "ahk_class XLMAIN"
        }
    }

    comp.render := (this) => this.Add(
        StackBox(App,
            {
                name: "fetch-fedex-resv-stack-box",
                groupbox: {
                    title: "FedEx 订单信息抓取",
                    options: "Section r6 @use:box"
                }
            },
            () => [
                App.AddText("xs10 yp+30 h20", "房号：   "),
                App.AddEdit("vroom-num x+10"),
                App.AddText("xs10 yp+30 h20", "确认号："),
                App.AddEdit("vconf-num x+10"),
                App.AddButton("vfetchfedexresv-action xs10 y+10 w100 ", "抓取订单信息").onClick(action)
            ]
        )
    )

    return comp
}