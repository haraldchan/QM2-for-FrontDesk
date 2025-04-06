class BriefingSHeets_Data {
    static template := {
        onDayGroup: A_ScriptDir . "\Excel\On-Day Group Details Template.xls",
        shiftBriefingLog: A_ScriptDir . "\Excel\Shift Briefing Log Template.xls"
    }

    static parseGroupRoomingList(xmlPath) {
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)

        groupInfos := []
        groupElements := xmlDoc.getElementsByTagName("G_GRP1")

        loop groupElements.Length {
            group := groupElements[A_Index - 1]
            groupDetails := {}
            groupDetails.blockName := group.selectSingleNode("BLOCK_CODE").value
            groupDetails.blockCode := group.selectSingleNode("DESCRIPTION").value

            groupDetails.arrival := 0
            groupDetails.stayOver := 0
            groupDetails.departure := 0
            comments := []

            bookings := group.getElementsByTagName("G_CONFIRMATION_NO")
            loop bookings.Length {
                booking := bookings[A_Index - 1]
                arr := booking.selectSingleNode("ARRIVAL").value.split("-")
                arrFormatted := "20" . arr[3] . arr[1] . arr[2]
                
                dep := booking.selectSingleNode("DEPARTURE").value.split("-")
                depFormatted := "20" . dep[3] . dep[1] . dep[2]

                status := booking.selectSingleNode("RESV_STATUS").value

                if (DateDiff(arrFormatted, A_Now, "Days") >= 1) {
                    arrival++
                } else if (DateDiff(depFormatted, A_Now, "Days") == 1) {
                    departure++
                } else {
                    stayOver++
                }

                comment := groupDetails.blockCode.includes("FEDEX") 
                    ? "RM INCL 1BBF TO CO" 
                    : booking.selectedSingleNode("LIST_G_COMMENT_RESV_NAME_ID/G_COMMENT_RESV_NAME_ID/RES_COMMENT").value
                comments.Push(comment)
            }
            
            groupDetails.comments := comments.unique()
            groupInfos.Push(groupDetails)
        }

        xmlDoc := ""
        return groupInfos
    }

    static parseCompHseu(xmlPath) {
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)

        freeGuests := []
        roomElements := xmlDoc.getElementsByTagName("ROOM")
        nameElements := xmlDoc.getElementsByTagName("FULL_NAME")
        mktElements := xmlDoc.getElementsByTagName("MARKET_CODE")

        loop roomElements.Length {
            roomNum := roomElements[A_Index - 1].ChildNodes[0].nodeValue
            name := nameElements[A_Index - 1].ChildNodes[0].nodeValue.split(",")
            rateCode := mktElements[A_Index - 1].ChildNodes[0].nodeValue == "HSE" ? "HSEU" : "COMP"

            freeGuests.Push({
                roomNum: Integer(roomNum),
                name: name[1] . " " . name[2],
                rateCode: rateCode
            })
        }

        xmlDoc := ""

        return freeGuests
    }

    static parseVipArr() {

    }

    static parseVipDep() {

    }
}