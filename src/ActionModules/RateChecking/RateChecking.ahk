#Include "./RateChecking_Action.ahk"

RateChecking(App, props) {
    comp := Component(App, A_ThisFunc)

    s := useProps(props.styles, {
        xPos: "x30 ",
        yPos: "y460 ",
        wide: "w350 "
    })

    history := []
    curPtr := history.Length || 1
    HIS_LENGTH := 5
    handleHistoryUpdate(confNums) {
        history.Push(confNums)

        if (history.Length > HIS_LENGTH) {
            history.RemoveAt(1)
        }

        curPtr := history.Length
    }

    handleHistoryNavigate(scf, direction) {
        if (!history.Length) {
            return
        }

        if (direction == "Up") {
            if (curPtr == 1) {
                scf.Value := history[1]
                return
            }
            scf.Value := history[curPtr - 1]
            curPtr--
        } else {
            if (curPtr == history.Length) {
                scf.Value := history[history.Length]
                return
            }
            scf.Value := history[curPtr + 1]
            curPtr++
        }
    }

    action(*) {
        form := comp.submit()
        if (!form.suptConfNums) {
            return
        }

        handleHistoryUpdate(form.suptConfNums)
        App["suptConfNums"].Focus()

        WinHide(POPUP_TITLE)
        RateChecking_Action.USE(form.suptConfNums.trim())
        WinShow(POPUP_TITLE)
    }

    onMount() {
        scf := App["suptConfNums"]

        HotIf((*) => scf.Focused)
        Hotkey "Up", (*) => (handleHistoryNavigate(scf, "Up"), scf.Focus())
        Hotkey "Down", (*) => (handleHistoryNavigate(scf, "Down"), scf.Focus())
    }

    comp.render := (this) => this.Add(
        App.AddGroupBox("Section r5 " . s.xPos . s.yPos . s.wide, "快速查看房价"),
        ; conf number(s)
        App.AddText("xs10 w150 h20 0x200 yp+30", "订单确认号 (空格分割)"),
        App.AREdit("vsuptConfNums y+10 w200 h20 0x200", ""),
        App.ARButton("vRateCheckingAction xs10 y+10 w100", "查看房价")
           .OnEvent("Click", action),
        onMount()
    )

    return comp
}
