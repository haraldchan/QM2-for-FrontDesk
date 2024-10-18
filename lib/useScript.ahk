class useScript {
    /**
     * Runs a specific script file.
     * @param {String} scriptFilename File path of the script needs to run.
     * @param {...String} [params] Parameters to pass in the script.
     */
    static run(scriptFilename, params*) {
        paramString := ""
        for param in params {
            paramString .= " " . param
        }

        Run scriptFilename . " " . paramString
    }

    /**
     * Runs script represent as string by creating a temporary .ahk file.
     * @param {String} script A string representing a JavaScript expression, statement, or sequence of statements.
     * @param {String} [tempFile] A temp file path. If omitted, it defaults to `A_ScriptDir . "\use-script-eval.ahk"`.
     */
    static runEval(script, tempFile := A_ScriptDir . "\use-script-eval.ahk") {
        s := script . "`n" . Format('FileDelete("{1}")', tempFile)

        if (FileExist(tempFile)) {
            FileDelete(tempFile)
        }

        FileAppend(s, tempFile, "UTF-8")
        Run tempFile
    }
}