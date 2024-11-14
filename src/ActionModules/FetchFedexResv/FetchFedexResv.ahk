#Include "./FetchFedexResv_Action.ahk"

FetchFedexResv(props) {
    App := props.App, 
    styles := props.styles

    ffr := Component(App, A_ThisFunc)
    ffr.description := "抓取 FedEx Opera 订单信息"

    action() {
        roomNum := App.getCtrlByName("roomNum")
        confNum := App.getCtrlByName("confNum")

        FetchFedexResv_Action.USE(roomNum.Value, confNum.Value)
        roomNum.Value := ""
        confNum.Value := ""

        roomNum.Focus()

        WinActivate "ahk_class XLMAIN"
    }

    ffr.render := (this) => this.Add(
        App.AddGroupBox("Section r5 " . styles.xPos . styles.yPos . styles.wide, "FedEx 订单信息抓取"),
        App.AddText("xs10 yp+30 h20", "房号：   "),
        App.AddEdit("vroomNum x+10"),
        App.AddText("xs10 yp+30 h20", "确认号："),
        App.AddEdit("vconfNum x+10"),
        App.AddReactiveButton("vFetchFedexResvAction xs10 y+10 w100 ", "抓取订单信息")
           .OnEvent("Click", (*) => action()),
)

    return ffr
}