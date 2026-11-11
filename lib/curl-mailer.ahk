class CurlMailer {
    __New(smtpUser, authCode, smtpUrl, curlPath := "curl.exe") {
        this.smtpUser := smtpUser
        this.authCode := authCode
        this.smtpUrl := smtpUrl
        this.curlPath := curlPath
    }

    CheckCurl() {
        ; Explicit executable path
        if InStr(this.curlPath, "\") || InStr(this.curlPath, "/")
            return FileExist(this.curlPath)
                ? true
                : Error("curl.exe not found: " this.curlPath)

        ; Search PATH
        try {
            shell := ComObject("WScript.Shell")
            exec := shell.Exec('where.exe "' this.curlPath '"')
            output := exec.StdOut.ReadAll()

            if (exec.ExitCode = 0 && Trim(output))
                return true

            return Error("curl.exe was not found on this computer.")
        } catch as err {
            return Error("Unable to check curl.exe: " err.Message)
        }
    }

    Send(to, subject, body, attachments := [], cc := []) {
        curlStatus := this.CheckCurl()

        if (curlStatus is Error)
            return curlStatus

        boundary := "----AHK_MIME_" A_TickCount
        crlf := "`r`n"

        ; Build MIME message
        eml := ""
        eml .= "From: " this.smtpUser crlf
        eml .= "To: " to crlf
        if (cc.Length) {
            eml .= "Cc: " this.JoinAddresses(cc) crlf
        }
        eml .= "Subject: =?UTF-8?B?" this.Base64EncodeText(subject) "?=" crlf
        eml .= "MIME-Version: 1.0" crlf
        eml .= 'Content-Type: multipart/mixed; boundary="' boundary '"' crlf
        eml .= crlf

        ; Message body
        eml .= "--" boundary crlf
        eml .= 'Content-Type: text/plain; charset="UTF-8"' crlf
        eml .= "Content-Transfer-Encoding: base64" crlf crlf
        eml .= this.WrapBase64(this.Base64EncodeText(body)) crlf

        ; Attachments
        for filePath in attachments {
            if !FileExist(filePath)
                throw Error("Attachment not found: " filePath)

            fileData := FileRead(filePath, "RAW")
            fileName := StrSplit(filePath, ["\", "/"]).Pop()

            eml .= "--" boundary crlf
            eml .= "Content-Type: " this.GetMimeType(filePath) crlf
            eml .= 'Content-Transfer-Encoding: base64' crlf
            eml .= 'Content-Disposition: attachment; filename="' fileName '"' crlf crlf
            eml .= this.WrapBase64(this.Base64EncodeBuffer(fileData)) crlf
        }

        eml .= "--" boundary "--" crlf

        ; Temporary files
        tempBase := A_Temp "\curlmail_" A_TickCount
        emlPath := tempBase ".eml"
        configPath := tempBase ".conf"

        FileAppend(eml, emlPath, "UTF-8-RAW")

        ; curl config keeps credentials out of the command line
        config := ""
        config .= "url = " this.CurlQuote(this.smtpUrl) "`n"
        config .= "user = " this.CurlQuote(this.smtpUser ":" this.authCode) "`n"
        config .= "mail-from = " this.CurlQuote(this.smtpUser) "`n"
        config .= "mail-rcpt = " this.CurlQuote(to) "`n"
        for address in (cc is Array ? cc : [cc]) {
            if (Trim(address) != "") {
                config .= "mail-rcpt = " this.CurlQuote(address) "`n"
            }
        }
        config .= "upload-file = " this.CurlQuote(emlPath) "`n"
        config .= "silent`n"
        config .= "show-error`n"

        FileAppend(config, configPath, "UTF-8-RAW")

        ; Execute curl
        shell := ComObject("WScript.Shell")
        command := this.CurlQuote(this.curlPath)
            . " --config " this.CurlQuote(configPath)

        exitCode := -1
        stdout := ""
        stderr := ""

        try {
            process := shell.Exec(command)
            stdout := process.StdOut.ReadAll()
            stderr := process.StdErr.ReadAll()
            exitCode := process.ExitCode
        } finally {
            try FileDelete(configPath)
        }

        return {
            ok: exitCode = 0,
            exitCode: exitCode,
            stdout: stdout,
            stderr: stderr,
            emlPath: emlPath
        }
    }

    Base64EncodeText(text) {
        byteCount := StrPut(text, "UTF-8") - 1
        buff := Buffer(byteCount)
        StrPut(text, buff, "UTF-8")
        return this.Base64EncodeBuffer(buff)
    }

    Base64EncodeBuffer(buff) {
        if buff.Size = 0
            return ""

        chars := Buffer(4, 0)

        ; First call obtains the required output size
        DllCall("Crypt32\CryptBinaryToStringW",
            "Ptr", buff.Ptr,
            "UInt", buff.Size,
            "UInt", 0x40000001, ; BASE64 | NOCRLF
            "Ptr", 0,
            "Ptr", chars.Ptr)

        charCount := NumGet(chars, 0, "UInt")
        output := Buffer(charCount * 2)

        if !DllCall("Crypt32\CryptBinaryToStringW",
            "Ptr", buff.Ptr,
            "UInt", buff.Size,
            "UInt", 0x40000001,
            "Ptr", output.Ptr,
            "Ptr", chars.Ptr)
            throw OSError()

        return StrGet(output, "UTF-16")
    }

    WrapBase64(text, lineLength := 76) {
        result := ""
        while StrLen(text) > lineLength {
            result .= SubStr(text, 1, lineLength) "`r`n"
            text := SubStr(text, lineLength + 1)
        }
        return result text
    }

    CurlQuote(value) {
        q := Chr(34)
        value := StrReplace(value, "\", "\\")
        value := StrReplace(value, q, "\" q)
        return q value q
    }

    GetMimeType(filePath) {
        ext := StrLower(RegExReplace(filePath, "^.*\."))
        mimeTypes := Map(
            "pdf", "application/pdf",
            "txt", "text/plain",
            "csv", "text/csv",
            "html", "text/html",
            "htm", "text/html",
            "jpg", "image/jpeg",
            "jpeg", "image/jpeg",
            "png", "image/png",
            "gif", "image/gif",
            "zip", "application/zip",
            "xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "xls", "application/vnd.ms-excel",
            "docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "doc", "application/msword"
        )

        return mimeTypes.Has(ext)
            ? mimeTypes[ext]
            : "application/octet-stream"
    }

    JoinAddresses(addresses) {
        return addresses is Array
            ? this.JoinArray(addresses, ", ")
            : addresses
    }

    JoinArray(arr, separator := ", ") {
        result := ""
        for i, value in arr
            result .= (i > 1 ? separator : "") value
        return result
    }
}