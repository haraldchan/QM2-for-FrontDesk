class PsbBatchCI {
    static name := "PsbBatchCI"
    static description := "批量上报 - 使用前请先打开旅业二期"
    static popupTitle := "PSB Check-in (Batch)"

    static USE() {
        if (!WinExist("ahk_class 360se6_Frame")) {
            MsgBox("请先打开 360 浏览器/ 旅业二期！", this.popupTitle, "4096 T2")
            utils.cleanReload(winGroup)
        }

        this.execute()
    }

    static execute(){
        WinActivate("ahk_class 360se6_Frame")
        Send "^+j"
        Sleep 1000

        Send "允许粘贴"
        Send "{Enter}"
        Sleep 1000

        A_Clipboard := this.JSnippet
        Send "^v"
        Send "{Enter}"
    }

    static JSnippet := "
    (
        function findSpan(label){
            return Array.from(document.querySelectorAll('span')).find((span) => span.innerText === label)
        }

        findSpan('未上报').click()

        const batchCheckin = setInterval(() => {
            setTimeout(() => {
                findSpan('修改').click()
            }, 1000)


            setTimeout(() => {
                findSpan('上报(R)').click()
            }, 4000)
            
            setTimeout(() => {
                if (findSpan('一同入住')) {
                    findSpan('一同入住').click()
                }
            }, 5000)

            if (findSpan('暂无数据')) {
                alert('已完成所有上报。')
                clearInterval(batchCheckin)
            }
        }, 2000)
    )"
}