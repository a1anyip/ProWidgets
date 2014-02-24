console.log("Execute script!!!");
//pw.script.showMessage("Executed script :)");
pw.script.prompt("message", "title", "button title", "default value", 2, function(value) {
	console.log("callback (value: " + value + ")");
	console.log("pw: " + pw);
	//console.log("pw.script: " + pw.script);
	pw.script.prompt("message 2", "title 2", "button title 2", "default value 2", 0, function(value) {});
})