//
//  Router.swift
//  
//
//  Created by Luca Archidiacono on 13.07.23.
//

import Foundation

/// When handling a request, the router just steps through its list of middleware until one of them doesn’t call next. And by that, finishes the request handling process.
public class Router {
    // Sequence of Middleware functions
    private var middleware = [Middleware]()
    
    // Add additional middlewares to the list
    func use(_ middleware: Middleware...) {
        self.middleware.append(contentsOf: middleware)
    }
    
    /**
     Why not just loop through the array and call the middleware directly? What is that next closure thing?
     The implementation of a Router can run completely asynchronously.
     When a middleware runs, it does not have to call next immediately!
     Which is also the reason why the next closure passed in is marked as @escaping.
     */
    func handle(request: IncomingMessage,
                response: ServerResponse,
                next upperNext: @escaping Next) {
        guard !middleware.isEmpty else { return upperNext() }
        
        var next: Next? = { _ in }
        var index = middleware.startIndex
        
        next = { args in
            // Sort of recursion. The closure is stored in a variable so that it can reference itself in its own body.
            // Calls middleware by calling itself (next) until it reaches the last middleware.
            // Then it stops calling next and calls the upperNext closure one by one back.
            let middleware = self.middleware[index]
            index = self.middleware.index(after: index)
            
            let isLastMiddleware = index == self.middleware.endIndex
            middleware(request, response, isLastMiddleware ? upperNext : next!)
        }
        
        next!()
    }
}

public extension Router {
    func get(_ path: String = "", middleware: @escaping Middleware) {
        use { request, response, next in
            guard request.header.method == .GET,
                  request.header.uri.hasPrefix(path)
            else { return next() }
            
            middleware(request, response, next)
        }
    }
}
