/**
 * TODO:
 * 3. if no query result, continue
 */

/**
 * Find the span element by innerText.
 * @param {string} innerText The innerText of the target span.
 * @returns {HTMLSpanElement}
 */
function findSpan(innerText) {
	return Array.from(document.querySelectorAll('span')).find((span) => span.innerText === innerText)
}

const rooms = []
const queryInput = document.querySelector('input[placeholder="请输入查询条件"]')
const queryBtn = findSpan('查 询')
const sortBtn = document.querySelectorAll('.cell')[7]

const change = new Event('input', {
	bubbles: true,
	cancelable: true,
})



// test search
queryInput.value = 712
queryInput.dispatchEvent(change)
queryBtn.click()
sortBtn.click()
sortBtn.click()

let okBtn 

let coBtn = findSpan('退房')
coBtn.style.color = 'red'

// setTimeout(() => {
	// okBtn = Array.from(document.querySelector('.el-message-box__btns').querySelectorAll('span')).find((span) => span.innerText === '确定')
	// cxlBtn = Array.from(document.querySelector('.el-message-box__btns').querySelectorAll('span')).find((span) => span.innerText === '取消')
	// cxlBtn.click()
// }, 500)

// rooms.forEach(room => {
	// coBtn = findSpan('退房')

// 	setTimeout(() => {
// 		setTimeout(() => {
// 			queryInput.value = room
// 			queryInput.dispatchEvent(change)
// 			queryBtn.click()
// 		}, 1000);

// 		// setTimeout(() => {
// 		// 	coBtn.click()
// 		// 	}, 2000);
			
// 		// setTimeout(() => {
// 		// 	okBtn.click()	
// 		// }, 4000);

// 	}, 2000);
// })

// alert('已完成退房。')