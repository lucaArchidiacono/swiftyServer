//
//  Logger.swift
//  
//
//  Created by Luca Archidiacono on 13.07.23.
//

import Foundation

public func log(request: IncomingMessage,
                response: ServerResponse,
                next: @escaping Next) {
    let userAgentDescr = "User-Agent: \(request.header.headers.first(name: "User-Agent") ?? "-")"
    let startFinishBlock = String(repeating: "*", count: userAgentDescr.count)
    let description = """
        \(startFinishBlock)
        Method: \(request.header.method)
        URL: \(request.header.uri)
        \(userAgentDescr)
        """
    print(description)
    next()
}
