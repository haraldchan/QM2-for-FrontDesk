#Include "../Phrases/RushRoom.ahk"
#Include "../Phrases/Upsell.ahk"
#Include "../Phrases/ExtraBed.ahk"
#Include "../Phrases/TableResv.ahk"

Phrases(App){
	phrases := [RushRoom, Upsell, ExtraBed, TableReserve]

    selectedPhrase := signal(ExtraBed.description)
	phraseComponents := Map()
	for phrase in phrases {
		phraseComponents[phrase.description] := Map(phrase, App)
	}

    return (
        phraseComponents.keys().map(phrase => 
			App.AddRadio((phrase = selectedPhrase.value ? "Checked" : "") . " w200 h25", phrase)
			   .OnEvent("Click", (*) => selectedPhrase.set(phrase))
		),
		Dynamic(selectedPhrase, phraseComponents)
    )
}