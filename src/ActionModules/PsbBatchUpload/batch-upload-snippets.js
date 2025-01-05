function findSpan(label) {
	return Array.from(document.querySelectorAll('span')).find((span) => span.innerText === label)
}

async function executeUpload() {
    await delay(0, () => findSpan('修改').click())
	await delay(2000, findSpan('上报(R)').click())
	await delay(2000, () => findSpan('一同入住') && findSpan('一同入住').click())
}

function delay(ms, func) {
    return new Promise((resolve) => {
        setTimeout(() => {
            console.log('Executing: ' + func.name)
			func()
			resolve()
		}, ms)
	})
}

findSpan('未上报').click()
executeUpload()

const batchUpload = setInterval(() => {
    if (findSpan('暂无数据')) {
		clearInterval(batchCheckin)
        alert('已完成所有上报。')
    }
    executeUpload()
}, 5000)