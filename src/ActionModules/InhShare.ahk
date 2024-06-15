class InhShare {
	static description := "生成空白 In-House Share"

	static USE(initX := 949, initY := 599) {
		WinMaximize "ahk_class SunAwtFrame"
		WinActivate "ahk_class SunAwtFrame"
		Sleep 1000
		WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
		BlockInput true
		; Sleep 100
		Send "!t"
		; Sleep 200
		utils.waitLoading()
		Send "!s"
		utils.waitLoading()
		Send "!m"
		utils.waitLoading()
		Send "{Esc}"
		utils.waitLoading()
		Send "{Text}1"
		utils.waitLoading()
		loop 4 {
			Send "{Tab}"
			utils.waitLoading()
		}
		Send "{Text}0"
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send "{Text}6"
		utils.waitLoading()
		Send "!o"
		utils.waitLoading()
		Send "!r"
		utils.waitLoading()
		MouseMove initX, initY ; 949, 599
		utils.waitLoading()
		Click
		utils.waitLoading()
		Send "!d"
		MouseMove initX - 338, initY - 53 ; 611, 546
		utils.waitLoading()
		Click
		utils.waitLoading()
		Send "!c"
		MouseMove initX - 625, initY - 92 ; 324, 507
		utils.waitLoading()
		Click "Down"
		MouseMove initX - 737, initY - 79 ; 212, 520
		utils.waitLoading()
		Click "Up"
		utils.waitLoading()
		Send "{Text}NRR"
		utils.waitLoading()
		Send "!o"
		utils.waitLoading()
		loop 4 {
			Send "{Esc}"
			utils.waitLoading()
		}
		utils.waitLoading()
		Send "!i"
		utils.waitLoading()
		loop 5 {
			Send "{Esc}"
			utils.waitLoading()
		}
		utils.waitLoading()
		Send "{Space}"
		utils.waitLoading()
		Send "!o"
		utils.waitLoading()
		Send "!c"
		utils.waitLoading()
		BlockInput false
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
	}
}