//
//  main.swift
//
//
//  Created by Luca Archidiacono on 12.07.23.
//

let server = Server()

// MARK: Middleware
// Middleware to parse url queryItems
server.use(queryString(request:response:next:))
// Middleware to log requests
server.use(log(request:response:next:))

// MARK: Get and render page
server.get("/self") { request, response, next in
    response.render(.self)
}
server.get("/swifty") { request, response, next in
    response.render(.swifty)
}
server.get { request, response, next in
    response.render(.welcome)
}

server.listen(8888)
