function init() {
	PW.loadPlist("JSTest.plist");
	PW.setTitle("JSTest Changed");
	PW.setButtonText("Done");
}

function action(options, text) {
	
	var text = text.replace(/[a-zA-Z]+/g, "-");
	var option = options['option'];
	
	var accessToken = PW.getPreferenceValue("accessToken");
	var requestURL = "http://evernote.com/api/publish_note?access_token=" + accessToken;
	var requestParams = {
		title: "JSTest Title " + option,
		content: text
	};
	
	PW.request(requestURL, "POST", requestParams, function(err, response) {
		if (err != 0) { // there is some errors
			PW.alert("Error", response);
			PW.focusText();
		} else {
			PW.alert("Success", response);
			PW.close();
		}
	});
}