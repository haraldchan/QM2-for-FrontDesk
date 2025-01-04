function findSpan(label) {
	return Array.from(document.querySelectorAll('span')).find((span) => span.innerText === label)
}

// sequence funcs
async function executeSequence(room) {
	await delay(0, roomQuery, room)
	await delay(2000, clickCheckout)
	await delay(2000, clickOk)
}

function delay(ms, func, ...args) {
	return new Promise((resolve) => {
		setTimeout(() => {
			console.log(`Executing: ${func.name}`)
			func(...args)
			resolve()
		}, ms)
	})
}

function roomQuery(room) {
	queryInput.value = room
	queryInput.dispatchEvent(change)
	queryBtn.click()
	console.log('roomQuery executed')
}

function clickCheckout() {
	sortBtn.click()
	sortBtn.click()
	coBtn = findSpan('退房')
	coBtn.click()
	console.log('clickCheckout executed')
}

function clickOk() {
	let okBtn = Array.from(document.querySelector('.el-message-box__btns').querySelectorAll('span')).find((span) => span.innerText === '确定')
	okBtn.click()
	console.log('clickOk executed')
}

// initializing
const rooms = []
const queryInput = document.querySelector('input[placeholder="请输入查询条件"]')
const queryBtn = findSpan('查 询')
const sortBtn = document.querySelectorAll('.cell')[7]
const change = new Event('input', {
	bubbles: true,
	cancelable: true,
})

let index = 0
const loop  = setInterval(() => {
	if (index > rooms.length) {
		clearInterval(loop)
		return
	}
	console.log('Starting sequence...')
	executeSequence(rooms[index])
	index++
}, 10000) 