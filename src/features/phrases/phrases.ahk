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

	App.defineDirectives(
		"@use:phrase-box-xyw", "x30 @relative[y+10]:phrases-radio-group w350 @use:bold",
		"@use:phrases-text", "xs10 yp+30 w50 h20 0x200",
		"@use:phrases-edit", "x+10 w150 h20 "
	)

	return (
        StackBox(App, 
            {
                groupbox: { options: "vphrases-radio-group Section x30 y+10 w350 Hidden " . Format("h{1}", 30 * phrases.keys().Length) } 
            },
			() => phrases.keys().map(phrase =>
				App.AddRadio(A_Index == 1 ? "xs1 h20 yp+1" : "xs1 h20 yp+30", phrases[phrase])
				   .onClick((*) => selectedPhrase.set(phrase.name))
			),
			
        ),
		App.AddButton("vphrase-copy @relative[x-100;y+30]:phrases-radio-group w90 h55", "复制为`nComment`nAlert"),
		Dynamic(App, selectedPhrase, phraseComponents,, &componentInstances),
		onMount(componentInstances)
	)
}