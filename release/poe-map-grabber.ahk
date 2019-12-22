#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include <Jxon>

fallBackVersion := "v1.0.0"
fallBackCurrentLeagues := ["Metamorph", "Hardcore Metamorph", "Standard", "Hardcore"]
fallBackMapSeries := "metamorph"

Gui, Add, Text, y10, Account:
Gui, Add, Edit, vaccountInput y6 w90 x65
Gui, Add, Text, y10 vtxtUpdate, GHub check failed
Gui, Add, Text, x14 y35, League:
Gui, Add, DropDownList, vcurLeague x65 y33 w120
Gui, Add, Text, x200 y35 w30 vtxtVersion
Gui, Add, CheckBox, Checked x10 y60 vTier1, Tier 1 
Gui, Add, CheckBox, Checked vTier2, Tier 2
Gui, Add, CheckBox, Checked vTier3, Tier 3
Gui, Add, CheckBox, Checked vTier4, Tier 4
Gui, Add, CheckBox, Checked x70 y60 vTier5, Tier 5
Gui, Add, CheckBox, Checked vTier6, Tier 6
Gui, Add, CheckBox, Checked vTier7, Tier 7
Gui, Add, CheckBox, Checked vTier8, Tier 8
Gui, Add, CheckBox, Checked x130 y60 vTier9, Tier 9
Gui, Add, CheckBox, Checked vTier10, Tier 10
Gui, Add, CheckBox, Checked vTier11, Tier 11
Gui, Add, CheckBox, Checked vTier12, Tier 12
Gui, Add, CheckBox, Checked x190 y60 vTier13, Tier 13
Gui, Add, CheckBox, Checked vTier14, Tier 14
Gui, Add, CheckBox, Checked vTier15, Tier 15
Gui, Add, CheckBox, Checked vTier16, Tier 16

Gui, Add, Button, w80 x10 y137 vbtnQuery gStartQueryBtn, Query
Gui, Add, Button, w80 x95 y137 vbtnCancel gCancelQueryBtn, Cancel
Gui, Add, Button, w80 x95 y137 vbtnToggle gToggleTiersBtn, Toggle
Gui, Add, Button, w80 x180 y137 vbtnCopy gCopyResultBtn, Copy Result
Gui, Add, Text, x10, Don't search trade while query in progress!

Gui, Add, StatusBar,, Ready to start request.
GuiControl, Hide, btnCancel
GuiControl, Hide, btnCopy
Gui, Show, , PoE Map Grabber

version := ""
mapSeries := ""
progress := 0
total := 0
receivedData := {}
queryData := []
queriesInProgress := 0
error := 0
errorNum := 0

checkLatestVersion()
loadManifest()

return

StartQueryBtn:
	validateStart()
return

CancelQueryBtn:
	cancelQuery()
return

ToggleTiersBtn:
	toggleTiers()
return

CopyResultBtn:
	copyResult()
return

loadManifest() {
	global mapSeries, txtVersion, fallBackCurrentLeagues, fallBackMapSeries, fallBackVersion, version

	FileRead, f, ./Data/manifest.json
	data := Jxon_Load(f)

	if( data["leagues"] != "" && data["leagues"].Length() > 1 )
		populateLeagueList(data["leagues"])
	else
		populateLeagueList(fallBackCurrentLeagues)

	if( data["map_series"] != "" )
		mapSeries := data["map_series"]
	else
		mapSeries := fallBackMapSeries

	if( data["version"] != "" )
		version := data["version"]
	else
		version := fallBackVersion

	GuiControl, Text, txtVersion, % version

}

checkLatestVersion() {
	req := ComObjCreate("MSXML2.XMLHTTP.6.0")
	req.open("GET", "https://api.github.com/repos/zedor/poe-map-grabber/releases/latest", true)
	req.onreadystatechange := Func("githubResponse").Bind(req)
	req.send()
}

githubResponse( this ) {

	if( this.readyState != 4 ) ; not done yet
		return

	if( this.status == 200 ) { ; success
		bufferino := Jxon_Load(this.responseText)
		if( bufferino.name > version )
			GuiControl, Text, txtUpdate, Update on github
		else
			GuiControl, Text, txtUpdate, No update
	}
}

populateLeagueList( obj ) {
	Loop % obj.Length() {
		GuiControl,, curLeague, % obj[A_Index]
	}
	GuiControl, Choose, curLeague, 1
}

toggleTiers() {
	Gui, Submit, NoHide
	global Tier1, Tier2, Tier3, Tier4, Tier5, Tier6, Tier7, Tier8, Tier9, Tier10, Tier11, Tier12, Tier13, Tier14, Tier15, Tier16
	Loop, 16 {
		if( Tier%A_Index% = 0 )
			GuiControl,, Tier%A_Index%, 1
		else
			GuiControl,, Tier%A_Index%, 0
	}
}

validateStart() {
	Gui, Submit, NoHide

	global accountInput

	if( accountInput = "" )
		return

	fillQueryData()
}

fillQueryData() {
	global queriesInProgress
	if( queriesInProgress > 0 ) {
		SB_SetText("Active Queries not resolved yet. Try again.")
		return
	}

	clearData()

	global Tier1, Tier2, Tier3, Tier4, Tier5, Tier6, Tier7, Tier8, Tier9, Tier10, Tier11, Tier12, Tier13, Tier14, Tier15, Tier16
	global total, progress, queryData

	FileRead, f, ./Data/mapList.json
	data := Jxon_Load(f)

	Loop % data.Length() {
		nameBuff = % data[A_Index].name
		buff = %A_Index%
		Loop % data[buff].tiers.Length() {
			tempVal = % data[buff].tiers[A_Index]
			if( Tier%tempVal%>0 ) {
				objBuff := {name: nameBuff, tier: tempVal}
				queryData.push(objBuff)
				++total
			}
		}
	}

	if( total < 0 ) {
		clearData()
		return
	}

	GuiControl, Show, btnCancel
	GuiControl, Hide, btnQuery
	GuiControl, Hide, btnToggle
	GuiControl, Hide, btnCopy
	
	;global fn
	fn := Func("traverseTheQuery")
	SetTimer % fn, 375
	;traverseTheQuery()
}

queriesComplete() {
	global receivedData, progress, total, queryData, error

	fn := Func("traverseTheQuery")
	SetTimer % fn, Off

	SB_SetText("Query successful. Copied to clipboard.")
	GuiControl, Show, btnCopy

	progress := 0
	total := 0
	queryData := []
	error := 0

	buffJsonString := Jxon_Dump(receivedData)
	clipboard := StrReplace(buffJsonString, ",""REPLPROP"":""REPL""" , "")
}

traverseTheQuery() {
	global queryData, accountInput, queriesInProgress, error, total, progress

	if( total > 0 && progress = total ) {
		if( queriesInProgress > 0 )
			msgbox Shouldnt happen! Code EXC01: queries still active while progress equals to total.
		queriesComplete()
	}

	if( queryData.Length() = 0 && error = 0 ) {
		if( queriesInProgress = 0 ) {
			GuiControl, Show, btnQuery
			GuiControl, Hide, btnCancel
			GuiControl, Show, btnToggle
			fn := Func("traverseTheQuery")
			SetTimer % fn, Off
		}
		return
	}

	if( error = 1 ) {
		progress := 0
		total := 0
		queryData := []
		error := 0
		receivedData := {}

		return
	}

	calculateETA()

	runQueryRequest( accountInput, queryData[1].tier, queryData[1].name )
	++queriesInProgress

	queryData.removeAt(1)

}

calculateETA() {
	global total, progress, error
	
	eta := (total-progress) * 0.375
	eta := Round(ETA)
	if( error = 0 && total > 0) {
		text := % "Progress`: " . progress . " of " . total . "`; ETA`: " . eta . "s"
		SB_SetText(text)
	}
}

clearData() {
	global progress, total, receivedData, queryData, error, errorNum

	progress := 0
	total := 0
	receivedData := {}
	queryData := []
	error := 0
	errorNum := 0
}

cancelQuery() {
	global total, progress, error, queriesInProgress

	if( total > progress && queriesInProgress = 0 && error = 0 ) {
		SB_SetText("Query cancelled.")
	}

	if( queriesInProgress > 0 && error = 0 ) {
		SB_SetText("Query cancelled. Waiting for requests to resolve.")
	} else if( error = 0 ) {
		GuiControl, Show, btnQuery
		GuiControl, Hide, btnCancel
		GuiControl, Show, btnToggle
		
		fn := Func("traverseTheQuery")
		SetTimer % fn, Off
	}

	clearData()
}

copyResult() {
	global receivedData

	buffJsonString := Jxon_Dump(receivedData)
	clipboard := StrReplace(buffJsonString, ",""REPLPROP"":""REPL""" , "")
}

runQueryRequest(account, tier, name) {
	global mapSeries, curLeague

	FileRead, d, ./Data/queryTemplate.json

	x := Jxon_Load(d)
	x["query", "filters", "map_filters", "filters", "map_tier", "max"] := tier
	x["query", "filters", "map_filters", "filters", "map_tier", "min"] := tier
	x["query", "filters", "map_filters", "filters", "map_series", "option"] := mapSeries
	x["query", "filters", "trade_filters", "filters", "account", "input"] := account
	x["query", "type", "option"] := name

	p := Jxon_Dump(x)

	req := ComObjCreate("MSXML2.XMLHTTP.6.0")
	req.open("POST", "https://www.pathofexile.com/api/trade/search/" . curLeague, true)
	req.SetRequestHeader("Content-type", "application/json`; charset=utf-8")
	req.onreadystatechange := Func("Ready").Bind(req, name, tier)
	req.send(p)
}

Ready(this, name, tier) {
	global receivedData, progress, total, queriesInProgress, error, errorNum

	if( this.readyState != 4 ) ; not done yet
		return
		
	if( this.status == 200 ) {	; 200 = success! this.responseText is our data.
		--queriesInProgress
		if( total = 0 || error = 1 )
			return

		buffRes := Jxon_Load(this.responseText)
		++progress
		if( receivedData[name] = "" ) { ; no such map saved yet
			receivedData[name] := {}
			receivedData[name, "REPLPROP"] := "REPL" ; added this to force objects. couldnt be arse learning how the json lib works and editing it
			receivedData[name, tier] := buffRes.total
		} else {
			receivedData[name, tier] := buffRes.total
		}
	} else {
		--queriesInProgress
		if( total = 0 || error = 1 )
			return

		if( this.status = 400 ) { ; bad request
			text := % "Error`: " . this.status . "`; Check account name / update script."
		} else if( this.status = 429 ) { ; request # over limit
			text := % "Error`: " . this.status . "`; Too many requests. Contact developer."
		} else if( this.status = 404 ) { ; not found
			text := % "Error`: " . this.status . "`; Server may be down."
		} else { ;
			text := % "Error`: " . this.status . "`; Google #, contact developer if needed."
		}

		SB_SetText(text)

		errorNum := this.status
		error := 1
	}

}

GuiClose:
ExitApp