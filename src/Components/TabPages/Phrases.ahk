#Include "../Phrases/RushRoom.ahk"
#Include "../Phrases/Upsell.ahk"
#Include "../Phrases/ExtraBed.ahk"
#Include "../Phrases/TableResv.ahk"

Phrases(App) {
	phrases := OrderedMap(
		RushRoom,  	  "Rush Room - 赶房与Key Keep",
		TableReserve, "Table Reserve - 餐饮预订",
		Upsell, 	  "Upselling - 房间升级",
		ExtraBed, 	  "Extra Bed - 加床",
	)

	selectedPhrase := signal(phrases.keys()[1].name)
	phraseComponents := OrderedMap()
	for phrase in phrases {
		phraseComponents[phrase.name] := phrase
	}

	return (
		phrases.keys().map(phrase =>
			App.AddRadio((phrase.name = selectedPhrase.value ? "Checked" : "") . " w200 h25", phrases[phrase])
			   .OnEvent("Click", (*) => selectedPhrase.set(phrase.name))
		),
		Dynamic(selectedPhrase, phraseComponents, { App: App, commonStyle: "x30 y350 w350" })
	)
}
