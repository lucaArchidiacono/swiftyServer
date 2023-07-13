//
//  IncomingMessage.swift
//  
//
//  Created by Luca Archidiacono on 12.07.23.
//

import NIOHTTP1

public class IncomingMessage {
    let header: HTTPRequestHead
    var userInfo = [String: Any]()
        
    init(header: HTTPRequestHead) {
        self.header = header
    }
}
