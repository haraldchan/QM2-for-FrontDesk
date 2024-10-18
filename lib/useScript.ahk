class useScript {
    static run(scriptFilename, params*) {
        paramString := ""
        for param in params {
            paramString .= " " . param
        }

        Run scriptFilename . " " . paramString
    }

    static runEval(script) {
        filePattern := A_ScriptDir . "\use-script-eval.ahk"
        s := script . "`n" . Format('FileDelete("{1}")', filePattern)

        if (FileExist(filePattern)) {
            FileDelete(filePattern)
        }

        FileAppend(s, filePattern, "UTF-8")
        Run filePattern
    }
}