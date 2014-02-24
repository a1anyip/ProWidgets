
function testMail() {
	
	console.log("===== mail test cases =====");
	
	// retrieve API
	var mailAPI = pw.api.mail;
	console.log("API: <" + mailAPI + ">");
	
	// test: availableSenderAccounts
	console.log("[availableSenderAccounts]");
	var ac = mailAPI.availableSenderAccounts();
	console.log("All sender account count: " + ac.length);
	console.log("All sender account #0: " + ac[0]);
	console.log("All sender account #1: " + ac[1]);
	console.log("All sender account #2: " + ac[2]);
}

function testAlarm() {
	
	console.log("===== alarm test cases =====");
	
	// retrieve API
	var alarmAPI = pw.api.alarm;
	console.log("API: <" + alarmAPI + ">");
	
	// test: allAlarms
	console.log("[allAlarms]");
	var allAlarms = alarmAPI.allAlarms();
	console.log("All alarm count: " + allAlarms.length);
	console.log("All alarm #0: " + allAlarms[0]);
	console.log("All alarm #1: " + allAlarms[1]);
	console.log("All alarm #2: " + allAlarms[2]);
	
	// test: getById
	console.log("[getById]");
	var invalidId = "TEST";
	var invalidAlarm = alarmAPI.getById(invalidId);
	console.log("Invalid alarm: " + invalidAlarm);
	
	// test: alarm info
	console.log("[Alarm info]");
	
	var infoOfAlarm = function(alarm) {
		var id = alarm.alarmId;
		var active = alarm.active;
		var hour = alarm.hour;
		var minute = alarm.minute;
		var repeatDays = alarm.repeatDays;
		var allowsSnooze = alarm.allowsSnooze;
		var sound = alarm.sound;
		var soundType = alarm.soundType;
		return "<Alarm info: " + id + "; " + (active ? "Active" : "Inactive") + "; " + hour + ":" + minute + "; " + repeatDays + "; allowsSnooze: " + (allowsSnooze ? "Yes" : "NO") + "; Sound: " + sound + " (" + soundType + ")>";
	};
	
	console.log("All alarm #0: " + infoOfAlarm(allAlarms[0]));
	console.log("All alarm #1: " + infoOfAlarm(allAlarms[1]));
	console.log("All alarm #2: " + infoOfAlarm(allAlarms[2]));
	
	// test: modify alarm
	console.log("[Modify alarm]");
	var testAlarm = allAlarms[0];
	var originalActive = testAlarm.active;
	var newActive = !originalActive;
	console.log("Changing the alarm state of the test alarm from " + (originalActive ? "YES" : "NO") + " to " + (newActive ? "YES" : "NO"));
	console.log("Current state: " + (testAlarm.active ? "YES" : "NO"));
}

pw.widget.willPresent = function() {
	pw.widget.setActionButtonText("Yo!");
	pw.widget.setTitle(pw.widget.name);
	pw.widget.setPreferredTintColor("cyan");
	pw.widget.setPreferredBarTextColor("white");
	var firstitem = pw.widget.itemAtIndex(0);
	firstitem.title = "Changed Title";
	firsttime.itemValueChangedEventHandler = function(oldValue) {
		console.log("firstitem: " + firstitem)
		pw.widget.showMessage("new: " + firstitem.value + "\nold: " + oldValue);
	}
}

pw.widget.didPresent = function() {
	pw.request.send("http://prowidgets.net/", null, null, null, function(success, statusCode, response, error) {
		//pw.widget.showMessage("status code: " + statusCode);
		pw.widget.setTitle("Loaded");
	});
};

pw.widget.itemValueChangedEventHandler = function(item, oldValue) {
	pw.widget.setTitle(oldValue);
	console.log("pw.widget.itemValueChangedHandler");
	console.log(item);
	console.log(oldValue);
}

pw.widget.actionEventHandler = function(values) {
	pw.widget.setTitle("action!");
	//pw.widget.removeItemAtIndex(0, true);
	//testMail();
	//testAlarm();
}