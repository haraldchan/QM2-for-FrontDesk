function findElements(tagName, label) {
	return Array.from(document.querySelectorAll(tagName)).find((el) => el.innerText === label)
}

// sequence funcs
async function executeCheckout(guest, index, qty) {
	await delay(0, idQuery, guest)
	await delay(1500, clickCheckout)
	await delay(1500, clickOk, guest, index, qty)
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

function idQuery(guest) {
	queryInput.value = guest.id
	queryInput.dispatchEvent(change)
	queryBtn.click()
	// console.log('idQuery executed')
}

function clickCheckout() {
	coBtn = findElements('span', '退房')
	coBtn.click()
	// console.log('clickCheckout executed')
}

function clickOk(guest, index, qty) {
	let okBtn = Array.from(document.querySelector('.el-message-box__btns').querySelectorAll('span')).find((span) => span.innerText === '确定')
	okBtn.click()
	// console.log('clickOk executed')
	console.log(`${guest.roomNum}: ${guest.name} 已退房。 当前进度 ${index}/${qty}`)
}

// running script
const guests = {} // rooms will be replace by actual depart rooms when read by PsbBatchCheckout_Action.checkoutBatch
guests.sort((a, b) => a.roomNum - b.roomNum)

const queryInput = document.querySelector('input[placeholder="请输入查询条件"]')
const queryBtn = findElements('span', '查 询')
const sortDescentBtn = document.querySelector('.sort-caret.descending')
const change = new Event('input', {
	bubbles: true,
	cancelable: true,
})

findElements('span', '已上报').click()
findElements('li', '证件号码').click()
executeCheckout(guests[0])
let index = 1
const loop = setInterval(() => {
	if (index === rooms.length) {
		clearInterval(loop)
		alert('已完成拍 out。')
		return
	}
	console.log('Starting sequence...')
	executeCheckout(guests[index], index, guests.length)
	index++
}, 4000)