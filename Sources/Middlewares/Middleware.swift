//
//  Middleware.swift
//  
//
//  Created by Luca Archidiacono on 13.07.23.
//

import Foundation

public typealias Next = (Any...) -> Void
public typealias Middleware = (IncomingMessage, ServerResponse, @escaping Next) -> Void
