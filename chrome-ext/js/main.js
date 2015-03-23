
var copy = function(str) {
    // copy 用に textareaを作る
    var textArea = document.createElement("textarea");
    textArea.style.cssText = "position:absolute;left:-100%";

    document.body.appendChild(textArea);

    textArea.value = str;
    textArea.select();
    document.execCommand("copy");

    document.body.removeChild(textArea);
};

chrome.contextMenus.create({
	'title': 'Share this image on @ikr7gyazo', 
	'contexts': ['image'], 
	'onclick': function(info){
		var xhr = new XMLHttpRequest();
		xhr.addEventListener('load', function(e){
			if(xhr.readyState === 4 && xhr.status  === 200){
				var data;
				try{
					data = JSON.parse(xhr.responseText);
				}catch(e){
					alert(e);
				}
				copy(data.url);
				window.open(data.url, Math.random());
			}else{
				alert(xhr.statusText);
			}
		});
		xhr.open('POST', `http://localhost:3232/share/url?url=${info.srcUrl}`);
		xhr.send();
	}
});
