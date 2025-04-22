ScanInvoke() {
	scannerName := "Epson Perfection V19"
	savePath := "\\10.0.2.13\fd\01 FO PASSPORT SCANNING"
	temp := A_Desktop . "\temp.jpg"

	Win := Gui("+AlwaysOnTop", "启动扫描")
	Win.OnEvent("Close", (*) => Win.Destroy())
	HotIf (*) => WinExist("启动扫描")
	Hotkey "Esc", (*) => Win.Destroy()

	scan(*) {
		Win.Hide()

		; Save the scanned image
		saveName := Win.getCtrlByName("saveName").Value
		folder := Format("{1}\{2} {3}", savePath, FormatTime(A_Now, "yyyy-MM-dd"), saveName)
		if (!DirExist(folder)) {
			DirCreate(folder)
		}

		count := 1
		img := Format("{1}\{2}-{3}.jpg", folder, saveName, count)

		loop files, (folder . "\*.jpg") {
			count++
			img := Format("{1}\{2}-{3}.jpg", folder, saveName, count)
			if (FileExist(img)) {
				continue
			} else {
				break
			}
		}

		devMgr := ComObject("WIA.DeviceManager")
		for devInfo in devMgr.DeviceInfos {
			name := devInfo.Properties.Item("Name").Value
			if (InStr(name, scannerName)) {
				device := devInfo.Connect()
				firstItem := device.Items.Item(1)
				image := firstItem.Transfer()

				if FileExist(temp) {
					FileDelete(temp)
				}

				image.SaveFile(temp)
				loop {
					if (A_Index > 7) {
						MsgBox("扫描保存失败，请重试。", A_ThisFunc, "48 T5")
						Win.Destroy()
						devMgr := ""
						return
					}

					if (FileExist(temp)) {
						break
					}

					Sleep 500
				}
				FileMove(temp, img)

				if (MsgBox("扫描完成，立即查看？", A_ThisFunc, "OKCancel T5") == "OK") {
					Run img
				}

				Win.Destroy()
				devMgr := ""
				return
			}
		}

		MsgBox(Format("扫描仪（型号：{1}）未找到！", scannerName), A_ThisFunc, "48 4096 T2")
		devMgr := ""
		Win.Destroy()
	}

	return (
		Win.AddText("x10 h25 w80 0x200", "保存文件名"),
		Win.AddEdit("vsaveName x+10 h25 w120", ""),
		Win.AddButton("Default x10 y+15 w100 h30", "扫 描").OnEvent("Click", scan)
		Win.AddButton("x+10 w100 h30", "取 消").OnEvent("Click", (*) => Win.Destroy()),
		Win.Show()
	)
}