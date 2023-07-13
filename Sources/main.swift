//
//  main.swift
//  
//
//  Created by Luca Archidiacono on 12.07.23.
//

let server = Server()

// Middleware to parse url queryItems
server.use(queryString(request:response:next:))
// Middleware to log requests
server.use(log(request:response:next:))
server.get("/foo") { request, response, next in
    guard let text = request.param("text") else {
        next()
        return
    }
    response.send("Hello, \(text) world!")
}
server.get { request, response, next in
    response.send("Welcome to the swifty Server!")
}

server.listen(8888)
