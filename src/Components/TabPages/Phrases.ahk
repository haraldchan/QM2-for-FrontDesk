#Include "../Phrases/RushRoom.ahk"
#Include "../Phrases/Upsell.ahk"
#Include "../Phrases/ExtraBed.ahk"
#Include "../Phrases/TableResv.ahk"

Phrases(App){
	phrases := [
		RushRoom(App), 
		TableReserve(App),
		Upsell(App), 
		ExtraBed(App), 
	]

    selectedPhrase := signal(phrases[1].description)
	phraseComponents := OrderedMap()
	for phrase in phrases {
		phraseComponents[phrase.description] := phrase
	}

    return (
        phraseComponents.keys().map(phrase => 
			App.AddRadio((phrase = selectedPhrase.value ? "Checked" : "") . " w200 h25", phrase)
			   .OnEvent("Click", (*) => selectedPhrase.set(phrase))
		),
		Dynamic(selectedPhrase, phraseComponents)
    )
}