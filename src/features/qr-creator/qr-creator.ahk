/**
 * @param {Svaner} App 
 */
QrCreator(App) {
    handleQrCodeCreate(*) {
        text := App["qr-text-content"].Value
        if (!text) {
            return
        }

        url := Format("https://api.2dcode.biz/v1/create-qr-code?data={}", utils.URIEncode(text))

        whr := ComObject("WinHttp.WinHttpRequest.5.1")

        whr.Open("GET", url, false)
        whr.Send()
        whr.WaitForResponse()

        stream := whr.ResponseStream

        f := FileOpen(A_Desktop "\qr-creator-temp.png", "w")

        buf := Buffer(8192)

        loop {
            bytesRead := 0

            ; IStream::Read = vtable index 3
            ComCall(3, stream,
                "ptr", buf,
                "uint", buf.Size,
                "uint*", &bytesRead
            )

            if (!bytesRead) {
                break
            }

            f.RawWrite(buf, bytesRead)
        }

        f.Close()

        whr := ""
        f := ""

        App["qr-code"].Value := A_Desktop "\qr-creator-temp.png"
    }

    handleSaveImage(*) {
        savepath := FileSelect("S", App["qr-text-content"].Value, "请选择保存位置", "PNG 文件 (*.png)")

        FileMove(A_Temp "\qr-creator-temp.png", savepath ".png")
    }

    render() {
        StackBox(App, {
            groupbox: {
                title: "二维码生成",
                options: "Section w355 h430",
            },
            font: { options: "s10.5 bold" }
        },
            () => [
                App.AddText("xs10 yp+30 w330", "请输入文本"),
                App.AddEdit("vqr-text-content xs10 yp+20 w330 h30", ""),
                StackBox(
                    App, {
                        groupbox: {
                            title: "",
                            options: "Section xs60 yp+40 w220 h230",
                        },
                        font: { options: "s10.5 bold" }
                    }, () => [
                        App.AddPic("vqr-code xs10 yp+20 w200 h200", ""),
                    ]
                ),
                App.AddButton("xs1 y+10 w100 h25", "生  成").onClick(handleQrCodeCreate),
                App.AddButton("x+20 w100 h25", "保  存").onClick(handleSaveImage),
            ]
        )
    }

    return render()
}