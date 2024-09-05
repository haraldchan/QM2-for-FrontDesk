#Include "../Phrases/RushRoom.ahk"
#Include "../Phrases/Upsell.ahk"
#Include "../Phrases/ExtraBed.ahk"
#Include "../Phrases/TableResv.ahk"

Phrases(App){
    selectedPhrase := signal("Extra Bed - 加床")
	phraseComponents := Map(
		"Rush Room - 赶房与Key Keep", Map(RushRoom, App),
		"Upselling - 房间升级", Map(Upsell, App),
		"Extra Bed - 加床", Map(ExtraBed, App),
		"Table Reserve - 餐饮预订", Map(TableReserve, App)
	)

    return (
        phraseComponents.keys().map(phrase => 
			App.AddRadio((phrase = selectedPhrase.value ? "Checked" : "") . " w200 h25", phrase)
			   .OnEvent("Click", (*) => selectedPhrase.set(phrase))
		),
		Dynamic(selectedPhrase, phraseComponents)
    )
}