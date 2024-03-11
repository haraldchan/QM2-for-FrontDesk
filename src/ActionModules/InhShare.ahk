#Include "../../../Lib/Classes/utils.ahk"

class InhShare {
	static description := "生成空白 In-House Share"

	static USE(initX := 949, initY := 599) {
		WinMaximize "ahk_class SunAwtFrame"
		WinActivate "ahk_class SunAwtFrame"
		Sleep 1000
		WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
		BlockInput true
		Sleep 100
		Send "!t"
		Sleep 200
		Send "!s"
		Sleep 200
		Send "!m"
		Sleep 700
		Send "{Esc}"
		Sleep 800
		Send "{Text}1"
		Sleep 350
		loop 4 {
			Send "{Tab}"
			Sleep 50
		}
		Send "{Text}0"
		Sleep 210
		Send "{Tab}"
		Sleep 50
		Send "{Tab}"
		Sleep 207
		Send "{Text}6"
		Sleep 1500
		Send "!o"
		Sleep 800
		Send "!r"
		Sleep 1000
		MouseMove initX, initY ; 949, 599
		Sleep 2000
		Click
		Sleep 200
		Send "!d"
		MouseMove initX - 338, initY - 53 ; 611, 546
		Sleep 200
		Click
		Sleep 1500
		Send "!c"
		MouseMove initX - 625, initY - 92 ; 324, 507
		Sleep 1000
		Click "Down"
		MouseMove initX - 737, initY - 79 ; 212, 520
		Sleep 200
		Click "Up"
		Sleep 200
		Send "{Text}NRR"
		Sleep 200
		Send "!o"
		Sleep 1000
		loop 4 {
			Send "{Esc}"
			Sleep 500
		}
		Sleep 3500
		Send "!i"
		Sleep 3000
		loop 5 {
			Send "{Esc}"
			Sleep 100
		}
		Sleep 1000
		Send "{Space}"
		Sleep 1000
		Send "!o"
		Sleep 300
		Send "!c"
		Sleep 300
		BlockInput false
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
	}
}