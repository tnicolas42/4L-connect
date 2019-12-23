var baseAPI = 'http://localhost:8000/api/'

function call(arg) {
	var request = new XMLHttpRequest()
	request.open('GET', baseAPI + arg, true)
	request.send()
	console.log('[API CALL]: /' + arg)
}

function setLed(arg) {
	call('setLed?enable=' + arg)
}
