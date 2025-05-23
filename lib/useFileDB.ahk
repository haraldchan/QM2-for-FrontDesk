class useFileDB {
	__New(dbSettings) {
		s := useProps(dbSettings, {
			main: dbSettings is Map ? dbSettings["main"] : dbSettings.main,
			archive: "",
			backup: "",
			cleanPeriod: 180
		})

		this.main := s.main
		this.archive := s.archive
		this.backup := s.backup
		this.cleanPeriod := s.cleanPeriod
	}

	/**
	 * 
	 * @param {String} jsonString 
	 * @param {String} date 
	 * @param {String} saveName 
	 */
	add(jsonString, date := FormatTime(A_Now, "yyyyMMdd"), saveName := JSON.parse(jsonString)["fileName"]) {
		dateFolder := "\" . date
		fileName := "\" . saveName . ".json"
		; create dateFolder if not exist yet
		if (!DirExist(this.main . dateFolder)) {
			DirCreate(this.main . dateFolder)
		}
		if (FileExist(this.main . dateFolder . fileName)) {
			return
		}
		FileAppend(jsonString, this.main . dateFolder . fileName, "UTF-8")
		Sleep 100
		; cleanup outdated if cleanPeriod is unset/0
		if (this.cleanPeriod > 0) {
			this.cleanup()
		}
	}

	/**
	 * 
	 * @param {String} db 
	 * @param {String}  queryDate 
	 * @param {Number}  queryPeriodInput 
	 */
	findByPeriod(db, queryDate, queryPeriodInput) {
		matchFilePaths := []
		loop files, (db . "\" . queryDate . "\*.json") {
			if (DateDiff(A_Now, A_LoopFileTimeCreated, "Minutes") <= queryPeriodInput) {
				matchFilePaths.InsertAt(1, A_LoopFileFullPath)
			}
		}
		return matchFilePaths
	}

	cleanup() {
		loop files, this.main . "\*", "D" {
			if (DateDiff(A_Now, A_LoopFileName, "Days") > this.cleanPeriod) {
				DirDelete(A_LoopFileFullPath, true)
			}
		}
	}

	/**
	 * 
	 * @param {String} db 
	 * @param {String}  queryDate 
	 * @param {Number}  queryPeriodInput 
	 * @return {Map[]}
	 */
	load(db := this.main, queryDate := FormatTime(A_Now, "yyyyMMdd"), queryPeriodInput := 60) {
		if (queryDate = FormatTime(A_Now, "yyyyMMdd")) {
			return this.loadOneDay(db, queryDate, queryPeriodInput)
		} else if (FileExist(this.archive . "\" . queryDate . " - archive.json")) {
			return this.loadArchiveOneDay(queryDate)
		} else {
			if (!FileExist(this.archive . "\" . queryDate . " - archive.json")) {
				if (DateDiff(A_Now, queryDate, "Days") > 0) {
					SetTimer(() => this.createArchive(queryDate), -100)
				}
				return this.loadOneDay(db, queryDate, 60 * 24 * this.cleanPeriod)
			}
		}
	}

	/**
	 * 
	 * @param {String} db 
	 * @param {String}  queryDate 
	 * @param {Number}  queryPeriodInput 
	 * @return {Map[]}
	 */
	loadOneDay(db := this.main, queryDate := FormatTime(A_Now, "yyyyMMdd"), queryPeriodInput := 60) {
		loadedPaths := this.findByPeriod(db, queryDate, queryPeriodInput)
		parsedProfiles := []

		for file in loadedPaths {
			str := FileRead(file, "UTF-8")
			try {
				parsedProfiles.Push(JSON.parse(str))
			} catch {
				parsedProfiles.InsertAt(A_Index, this._handleMalformedJson(str).map(profile => JSON.parse(profile))*)
			}
		}

		return parsedProfiles
	}

	/**
	 * @param {String} malformedString
	 * @returns {Array}
	 */
	_handleMalformedJson(malformedString) {
		if (!malformedString.includes("}{")) {
			return []
		}

		return JSON.parse("[" . malformedString.replace("}{", "}, {") . "]").map(profile => JSON.stringify(profile)).unique()
	}

	/**
	 * 
	 * @param newJsonString 
	 * @param queryDate 
	 * @param fileName 
	 */
	updateOne(newJsonString, queryDate, fileName) {
		loop files, (this.main . "\" . queryDate . "\*.json") {
			if (fileName . ".json" = A_LoopFileName) {
				FileDelete(A_LoopFileFullPath)
				FileAppend(newJsonString, this.main . "\" . queryDate . "\" . filename . ".json", "UTF-8")
			}
		}

		if (queryDate != FormatTime(A_Now, "yyyyMMdd")) {
			if (this.archive != "") {
				this.createArchive(queryDate)	
				FileDelete(this.archive . "\" . queryDate . " - archive.json")
			}
			if (this.backup != "") {
				this.createArchiveBackup(queryDate)
			}
		}
	}

	/**
	 * 
	 * @param archiveDate 
	 */
	createArchive(archiveDate) {
		archiveData := JSON.stringify(this.loadOneDay(, archiveDate, 60 * 24 * this.cleanPeriod))
		archiveFullPath := this.archive . "\" . archiveDate . " - archive.json"
		FileAppend(archiveData, archiveFullPath, "UTF-8")
	}

	/**
	 * 
	 * @param archiveDate 
	 * @return {Map[]}
	 */
	loadArchiveOneDay(archiveDate) {
		archiveFullPath := this.archive . "\" . archiveDate . " - archive.json"
		try {
			archivedData := JSON.parse(FileRead(archiveFullPath, "UTF-8"))
		} catch {
			this.createArchive(archiveDate)
			archivedData := JSON.parse(FileRead(archiveFullPath, "UTF-8"))
		}

		return archivedData
	}

	; createRecentBackup(period := 60) {
	; 	if (this.IS_BACKINGUP_RECENT = true) {
	; 		return
	; 	} else {
	; 		this.IS_BACKINGUP_RECENT := true
	; 	}
	; 	recentBackupFullPath := this.backup . "\recent.json"
	; 	recent := FileExist(recentBackupFullPath) ? JSON.parse(FileRead(recentBackupFullPath, "UTF-8")) : []
	; 	recent.Push(this.loadOneDay(, , period)*)

	; 	if (recent.Length > this.recentLength) {
	; 		recent.RemoveAt(1, recent.Length - this.recentLength)
	; 	}

	; 	if (FileExist(recentBackupFullPath)) {
	; 		FileDelete(recentBackupFullPath)
	; 	}

	; 	FileAppend(JSON.stringify(recent), recentBackupFullPath, "UTF-8")
	; 	this.IS_BACKINGUP_RECENT := false
	; }

	createArchiveBackup(backupDate) {
		archiveData := JSON.stringify(this.loadOneDay(, backupDate, 60 * 24 * this.cleanPeriod))
		monthFolder := "\" . SubStr(backupDate, 1, 6)
		backupFullPath := this.backup . monthFolder . "\" . backupDate . " - backup.json"

		if (!DirExist(this.backup . monthFolder)) {
			DirCreate(this.backup . monthFolder)
		}
		if (FileExist(backupFullPath)) {
			FileDelete(backupFullPath)
		}
		FileAppend(archiveData, backupFullPath, "UTF-8")
	}

	; restoreRecent() {
	; 	recent := JSON.parse(FileRead(this.backup . "\recent.json", "UTF-8"))
	; 	for snippet in recent {
	; 		this.add(JSON.stringify(snippet))
	; 	}
	; }

	restoreArchiveOneDay(restoreDate) {
		monthFolder := "\" . SubStr(restoreDate, 1, 6)
		loop files, (this.backup . monthFolder . "\*.json") {
			msgbox A_LoopFileName
			if (!InStr(A_LoopFileName, restoreDate)) {
				continue
			}

			archive := FileRead(A_LoopFileFullPath, "UTF-8")
			filename := StrReplace(A_LoopFileName, "backup", "archive")
			archiveFullPath := this.archive . "\" . filename

			if (FileExist(archiveFullPath)) {
				FileDelete(archiveFullPath)
			}
			FileAppend(archive, archiveFullPath, "UTF-8")
			break
		}
	}
}