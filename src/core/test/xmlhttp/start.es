/*
    Start http server
*/
require ejs.web

let address = ":" + (App.config.test.http_port || "6700")
let server: HttpServer = new HttpServer

server.on("readable", function (event, request) {
    // App.log.info(request.method, request.uri, request.scheme)
    Web.serve(request)
})

// App.log.info("Listen on " + address)
server.listen(address)
App.eventLoop()
