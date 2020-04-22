function quotemeta(string) {
    return string.replace(/(\W)/, "$1");
}

function isearch(pattern) {
    var regex = new RegExp(quotemeta(pattern), "i");
    var spans = document.getElementsByTagName('li');
    var length = spans.length;
    var applis = 0;
    for (var i = 0; i < length; i++) {
        var e = spans[i];
        if (e.className === "card") {
            if (e.innerHTML.match(regex)) {
                e.style.display = "list-item";
                applis += 1;
            } else {
                e.style.display = "none";
            }
        }
    }
    const elem = document.getElementById("applicable-number");
    elem.textContent = '該当件数:' + applis + '件';
}

function applicable() {
    const ulElement = document.getElementById("cards");
    const childElementCount = ulElement.childElementCount;
    const elem = document.getElementById("applicable-number");
    elem.textContent = '該当件数:' + childElementCount + '件';
}

window.onload = function () {
    applicable()
}
