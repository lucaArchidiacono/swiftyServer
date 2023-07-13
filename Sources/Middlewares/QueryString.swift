//
//  QueryString.swift
//  
//
//  Created by Luca Archidiacono on 13.07.23.
//

import Foundation

fileprivate let paramDictKey = "ch.lucaa.param"

public func queryString(request: IncomingMessage,
                        response: ServerResponse,
                        next: @escaping Next) {
    if let queryItems = URLComponents(string: request.header.uri)?.queryItems {
        request.userInfo[paramDictKey] = Dictionary(grouping: queryItems, by: { $0.name })
            .mapValues { urlQueryItems in
                urlQueryItems.compactMap{ $0.value }.joined(separator: ",")
            }
    }
    
    next()
}

extension IncomingMessage {
    /// Access query parameters, like:
    ///     let userId = req.param("id")
    ///     let token = req.param("token")
    func param(_ id: String) -> String? {
        return (userInfo[paramDictKey] as? [String: String])?[id]
    }
}
