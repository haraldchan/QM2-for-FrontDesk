#Include "../Phrases/RushRoom.ahk"
#Include "../Phrases/Upsell.ahk"
#Include "../Phrases/ExtraBed.ahk"
#Include "../Phrases/TableResv.ahk"
#Include "../Phrases/TableRequest.ahk"

Phrases(App) {
	phrases := OrderedMap(
		RushRoom,  	  "Rush Room - 赶房与Key Keep",
		TableReserve, "Table Reserve - 餐饮预订",
		TableRequest, "Table Request - 总机代订",
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
			writeClipboard := ObjBindMethod(
				componentInstances[phraseComponents.indexOf(phraseName)], 
				"writeClipboard"
			)
			
			App.getCtrlByName("phraseCopy")
			   .OnEvent("Click", (*) => writeClipboard(), -1)
		}

		handleSwapWriteClipboard("RushRoom")
	}

	return (
		phrases.keys().map(phrase =>
			App.AddRadio((phrase.name = selectedPhrase.value ? "Checked" : "") . " w200 h25", phrases[phrase])
			   .OnEvent("Click", (*) => selectedPhrase.set(phrase.name))
		),
		Dynamic(App, selectedPhrase, phraseComponents, { commonStyle: "x30 y400 w350" }, &componentInstances),
		App.AddButton("vphraseCopy x270 y430 w90 h55", "复制`nComment`nAlert"),
		onMount(componentInstances)
	)
}