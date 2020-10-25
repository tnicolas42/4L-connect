var baseAPI = 'http://192.168.0.1:8000/api/'
// var baseAPI = 'http://localhost:8000/api/'

var lowEssence = false;
var darkMode = true;

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
	console.log('[API CALL]: ' + baseAPI + arg)
	console.log(data)
	return data
}

function sleep(ms) {
	return new Promise(resolve => setTimeout(resolve, ms));
}

function setRelay(id, arg) {
	call('setRelay?id=' + id + '&enable=' + arg)
}

function setDarkMode(enable) {
	if (lowEssence) {
		return;
	}
	var body = document.getElementsByTagName("BODY")[0];
	if (enable) {
		darkMode = true;
		if (lowEssence == false)
			body.style.backgroundColor = "var(--backgroung-dark-color)";
	}
	else {
		darkMode = false;
		if (lowEssence == false)
			body.style.backgroundColor = "var(--backgroung-main-color)";
	}
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
			printPercent("essence", res.essencePercent, res.essenceVolt)
		} catch {
			console.log("unable to get essence")
		}
		try {
			printPercent("mainBattery", res.mainBatteryPercent, res.mainBatteryVolt)
		} catch {
			console.log("unable to get mainBattery")
		}
		try {
			if (res.secondaryBatteryVolt > 11)
				printPercent("alim", 100, res.secondaryBatteryVolt)
			else
				printPercent("alim", 0, res.secondaryBatteryVolt)
			} catch {
			console.log("unable to get secondaryBattery")
		}
		try {
			if (res.lowEssence)
				lowEssence = true;
			else
				lowEssence = false;
		} catch {
			console.log("unable to get low essence information")
		}
		var body = document.getElementsByTagName("BODY")[0];
		if (lowEssence) {
			body.style.backgroundColor = "var(--backgroung-error-color)";
		}
		else {
			if (darkMode) {
				body.style.backgroundColor = "var(--backgroung-dark-color)";
			}
			else {
				body.style.backgroundColor = "var(--backgroung-main-color)";
			}
		}
		await sleep(1000)
	}
}

update();
