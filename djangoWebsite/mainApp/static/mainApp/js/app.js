var baseAPI = 'http://localhost:8000/api/'

var data;

function call(arg) {
	var request = new XMLHttpRequest()
	request.open('GET', baseAPI + arg, true)
	request.onload = function() {
		if (request.status >= 200 && request.status < 400) {
			try {
				JSON.parse(this.response);
				data = JSON.parse(this.response);
			}
			catch {}
		}
		else {
			data = null
			console.error("error on API call");
		}
	}
	request.send()
	console.log('[API CALL]: /' + arg)
	console.log(data)
	return data
}

function sleep(ms) {
	return new Promise(resolve => setTimeout(resolve, ms));
}

function setLed(arg) {
	call('setLed?enable=' + arg)
}

function printPercent(name, percent, voltage = -1) {
	var element = document.getElementById(name);
	var text = element.firstChild;
	if (voltage == -1) {
		text.textContent = percent + "%"
	}
	else {
		text.textContent = percent + "% - " + voltage + "V"
	}
	element.style = "width:" + percent + "%"
	if (percent < 25 && element.classList.contains('w3-green')) {
		element.classList.remove("w3-green")
		element.classList.add("w3-red")
	}
	else if (percent >= 25 && element.classList.contains('w3-red')) {
		element.classList.remove("w3-red")
		element.classList.add("w3-green")
	}
}

async function update() {
	await sleep(500)
	while (1) {
		var res = call('getInfo')
		try {
			printPercent("essence", 100, res.essence)
		} catch {
			console.log("unable to get essence")
		}
		try {
			printPercent("mainBattery", res.mainBatteryPercent, res.mainBatteryVolt)
		} catch {
			console.log("unable to get mainBattery")
		}
		try {
			printPercent("secondaryBattery", res.secondaryBatteryPercent, res.secondaryBatteryVolt)
		} catch {
			console.log("unable to get secondaryBattery")
		}
		await sleep(1000)
	}
}

update();