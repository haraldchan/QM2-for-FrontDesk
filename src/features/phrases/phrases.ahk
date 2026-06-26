#Include phrases\rush-room.ahk
#Include phrases\table-request.ahk
#Include phrases\upsell.ahk
#Include phrases\extra-bed.ahk

/**
 * @param {Svaner} App
 */
Phrases(App) {
	phrases := OrderedMap(
		"Table Request - 餐厅订位", TableRequest,
		"Rush Room - 赶房与Key Keep", RushRoom,
		"Upselling - 房间升级", Upsell,
		"Extra Bed - 加床", ExtraBed
	)

	selectedPhrase := signal(phrases.keys()[1])

	onMount(componentInstances) {
		effect(selectedPhrase, handleSwapWriteClipboard)
		handleSwapWriteClipboard(phraseName) {
			writeClipboard := ObjBindMethod(componentInstances[phraseName], "writeClipboard")

			App["phrase-copy"].onClick(writeClipboard, -1)
		}

		handleSwapWriteClipboard(phrases.keys()[1])
	}

	App.defineDirectives(
		"@use:phrase-box-xyw", "x30 @relative[y+10]:phrases-radio-group w350",
		"@use:phrases-text", "xs10 yp+30 w50 h20 0x200",
		"@use:phrases-edit", "x+10 w150 h20 "
	)

	render() {
		StackBox(App, {
			groupbox: { options: "vphrases-radio-group Section x30 y+10 w350 Hidden " . Format("h{1}", 30 * phrases.keys().Length) }
		},
			() => phrases.keys().map(phrase =>
				App.AddRadio(A_Index == 1 ? "Checked xs1 yp+1 h20" : "xs1 yp+30 h20", phrase)
				   .onClick((*) => selectedPhrase.set(phrase))
			)
		)
		App.AddButton("vphrase-copy @relative[x-100;y+30]:phrases-radio-group w90 h50", "复制语句")
		Dynamic(App, selectedPhrase, phrases, , &componentInstances)
		onMount(componentInstances)
	}

	return render()
}