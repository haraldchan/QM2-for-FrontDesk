function findSpan(label) {
	return Array.from(document.querySelectorAll('span')).find((span) => span.innerText === label)
}

// sequence funcs
async function executeCheckout(room) {
	await delay(0, roomQuery, room)
	await delay(1500, clickCheckout)
	await delay(1500, clickOk, room)
}

function delay(ms, func, ...args) {
	return new Promise((resolve) => {
		setTimeout(() => {
			console.log('Executing: ' + func.name)
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
	coBtn = findSpan('退房')
	coBtn.click()
	console.log('clickCheckout executed')
}

function clickOk(room) {
	let okBtn = Array.from(document.querySelector('.el-message-box__btns').querySelectorAll('span')).find((span) => span.innerText === '确定')
	okBtn.click()
	console.log('clickOk executed')
	console.log(room + ' has checked out')
}

// running script
const rooms = {} // rooms will be replace by actual depart rooms when read by PsbBatchCheckout_Action.checkoutBatch
const queryInput = document.querySelector('input[placeholder="请输入查询条件"]')
const queryBtn = findSpan('查 询')
const sortDescentBtn = document.querySelector('.sort-caret.descending')
const change = new Event('input', {
	bubbles: true,
	cancelable: true,
})

findSpan('已上报').click()
sortDescentBtn.click()
executeCheckout(rooms[0])
let index = 1
const loop = setInterval(() => {
	if (index === rooms.length) {
		clearInterval(loop)
		alert('已完成拍 out。')
		return
	}
	console.log('Starting sequence...')
	executeCheckout(rooms[index])
	index++
}, 4000)