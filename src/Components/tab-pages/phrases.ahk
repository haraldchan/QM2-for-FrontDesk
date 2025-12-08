#Include "../phrases/rush-room.ahk"
#Include "../phrases/table-request.ahk"
#Include "../phrases/upsell.ahk"
#Include "../phrases/extra-bed.ahk"

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

	App.defineDirectives(
		"@use:phrase-box-xyw", "x30 y350 w350"
	)

	return (
		phrases.keys().map(phrase =>
			App.AddRadio((phrase.name = selectedPhrase.value ? "Checked" : "") . " w200 h25", phrases[phrase])
			   .onClick((*) => selectedPhrase.set(phrase.name))
		),
		App.AddButton("vphrase-copy x270 y380 w90 h55", "复制`nComment`nAlert"),
		Dynamic(App, selectedPhrase, phraseComponents,, &componentInstances),
		onMount(componentInstances)
	)
}