#Include phrases\rush-room.ahk
#Include phrases\table-request.ahk
#Include phrases\upsell.ahk
#Include phrases\extra-bed.ahk

/**
 * @param {Svaner} App
 */
Phrases(App) {
	phrases := OrderedMap(
		RushRoom,  	  "Rush Room - 赶房与Key Keep",
		TableRequest, "Table Request - 餐厅订位",
		Upsell, 	  "Upselling - 房间升级",
		ExtraBed, 	  "Extra Bed - 加床",
	)

	selectedPhrase := signal(phrases.keys()[1].name)
	phraseComponents := OrderedMap()
	for phrase in phrases {
		phraseComponents[phrase.name] := phrase
	}

	onMount(componentInstances) {
		effect(selectedPhrase, handleSwapWriteClipboard)
		handleSwapWriteClipboard(phraseName) {
			writeClipboard := ObjBindMethod(componentInstances[phraseName], "writeClipboard")
			
			App["phrase-copy"].onClick(writeClipboard, -1)
		}

		handleSwapWriteClipboard("RushRoom")
	}

	defineRadioStyle(index) {
		defaultStyle := " x30 y+10 h20 "

		switch index {
			case 1:
				return "Checked" . defaultStyle
			case phrases.keys().Length:
				return "vphrases-last-radio" . defaultStyle
			default:
				return defaultStyle
		}
	}

	App.defineDirectives(
		"@use:phrase-box-xyw", "x30 @relative[y+10]:phrases-last-radio w350",
		"@use:phrases-text", "xs10 yp+30 w50 h20 0x200",
		"@use:phrases-edit", "x+10 w150 h20 "
	)

	return (
		phrases.keys().map(phrase =>
			App.AddRadio(defineRadioStyle(A_Index), phrases[phrase])
			   .onClick((*) => selectedPhrase.set(phrase.name))
		),
		App.AddButton("vphrase-copy x270 @relative[y+30]:phrases-last-radio w90 h55", "复制为`nComment`nAlert"),
		Dynamic(App, selectedPhrase, phraseComponents,, &componentInstances),
		onMount(componentInstances)
	)
}