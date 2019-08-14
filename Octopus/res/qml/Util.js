

function getBaseName(filepath) {
    var index = filepath.lastIndexOf("/");
    return filepath.substr(index+1)
}

function getFileExt(filepath) {
    var index = filepath.lastIndexOf(".");
    return filepath.substr(index+1);
}

function randomNum(minNum,maxNum){
    switch(arguments.length){
        case 1:
            return parseInt(Math.random()*minNum+1,10);
        break;
        case 2:
            return parseInt(Math.random()*(maxNum-minNum+1)+minNum,10);
        break;
            default:
                return 0;
            break;
    }
}

function httpPostJson(url,args, func) {

    var fullurl = "http://" + settings.server_ip + url
    console.log('post', fullurl)
    var xhr = new XMLHttpRequest();

    xhr.onreadystatechange = function() {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                var data = JSON.parse(xhr.responseText);
                func(true, data)
            } else {
                func(false)
            }
        }
    }

    xhr.error = function() {
        func(false)
    }

    xhr.open("post", fullurl, true)

    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.send(JSON.stringify(args));
}

let cbMap = {}
let cbIndex = 0

let handlers = {}

function addCB(cb) {
    cbIndex ++
    cbMap[cbIndex] = cb

    return cbIndex
}

function takeCB(id) {
    let cb = cbMap[id]
    delete cbMap[id]

    return cb
}

function addHandler(key, cb, autodelete) {
    handlers[key] = { func:cb, autodelete:autodelete}
}

function delHandler(key) {
    delete handlers[key]
}

function getHandler(key) {
    return handlers[key]
}
