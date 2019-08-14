import QtQuick 2.13
import MyPlugins 1.0


import 'Util.js' as Util

Client {
    id: ws

    property bool islogin: false

    function dispatch(message) {
        var index = message.indexOf("}")
        var msg = JSON.parse(message.substr(0, index+1))

        console.log("recv", message)

        if (msg.err) {
            msgBox.show(msg.err)
        }

        var data = JSON.parse(message.substr(index+1))

        if (msg.cbid) {
            var cb = Util.takeCB(msg.cbid)
            cb(msg.err, data)
        }

        if (msg.route) {
            var cbinfo = Util.getHandler(msg.route)
            if (!cbinfo) {
                console.log("no handler", msg.route)
                return
            }

            cbinfo.func(msg.err, data)
            if (cbinfo.autodelete) {
                Util.delHandler(msg.route)
            }
        }
    }

    onFileReceived: {
        dispatch(message)
    }

    onTextReceived: {
        dispatch(message)
    }

    onConnected: {
        console.log("Socket onConnected: " + url.toString())
        send("login", {ID: parseInt(settings.userid), Password: settings.password})
    }

    onDisConnected: {
        console.log("Socket onDisConnected: " + url.toString())
        close();
    }

    onPong: {
    }

    function addHandler(key, cb, autodelete) {
        Util.addHandler(key, cb, autodelete)
    }

    function delHandler(key) {
        Util.delHandler(key)
    }

    function login(uid, pass) {
        settings.userid = uid
        settings.password = pass

        url = "ws://" + settings.server_ip + "/chat"
        console.log('connect to', url)
        open();
    }

    function pack(route, data, cb) {
        var pkg = {
            route: route,
        }

        if (cb) {
            pkg.cbid = Util.addCB(cb)
        }

        var args = JSON.stringify(data)
        pkg.argsSize = args.length

        var txt = JSON.stringify(pkg) +args
        console.log("send", txt)
        return txt
    }

    function send(route, data, cb) {
        sendText(pack(route, data, cb))
    }

    function sendFile(route, data, filePath, cb) {
        sendFileWithPrefix(pack(route, data, cb), filePath)
    }
}

