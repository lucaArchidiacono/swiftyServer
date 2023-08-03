//
//  HTMLTemplate.swift
//  
//
//  Created by Luca Archidiacono on 30.07.23.
//

import Foundation

enum Header: Joinable {
    case charset(Charset)
    case style(Set<Style>)
    
    var rawValue: String {
        switch self {
        case .charset(let charset):
            return "<meta charset='\(charset)'>"
        case .style(let content):
            return "<style>\(content.joined())</style>"
        }
    }
    
    static var `default`: Set<Self> {
        return [
            .charset(.utf8),
            .style([
                .body([
                    "font-family": "-apple-system, sans-serif"
                ]),
                .h1([
                    "color": "rgb(2, 123, 227)",
                    "border-bottom": "1px solid rgb(2, 123, 227)",
                    "padding-bottom": "0.1em",
                    "text-align": "center",
                    "font-size": "2em",
                ]),
                .code([
                    "font-family": "Courier, monospace",
                    "background-color": "#f0f0f0",
                    "padding": "0.2em 0.4em",
                    "border-radius": "3px",
                    "display": "block",
                ]),
            ])]
    }
}

enum Charset: String {
    case utf8 = "utf-8"
    case utf16 = "utf-16"
    case utf32 = "utf-32"
}

enum Style: Joinable {
    typealias Content = [String: String]
    case body(Content)
    case h1(Content)
    case code(Content)
    
    private var key: String {
        switch self {
        case .body:
            return "body"
        case .h1:
            return "h1"
        case .code:
            return "code"
        }
    }
    
    var rawValue: String {
        return build(key: key)
    }
    
    private func build(key: String) -> String {
        return """
        \(key) {
            \(content.map { "\($0.key): \($0.value);" }.joined(separator: "\n"))
        }
        """
    }
    
    private var content: Content {
        switch self {
        case .body(let content),
                .h1(let content),
                .code(let content):
            return content
        }
    }
}

struct HTMLTemplate {
    private let headers: Set<Header>
    private let title: String
    private let body: String
    
    init(title: String,
         headers: Set<Header> = Header.default,
         body: String
    ) {
        self.title = title
        self.headers = headers
        self.body = body
    }
    
    public func render() -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
         \(headers.joined())
         <title>\(title)</title>
        </head>
        <body>
         \(body)
        </body>
        </html>
        """
    }
}

protocol Joinable: Hashable {
    var rawValue: String { get }
}

extension Set where Element: Joinable {
    func joined(separator: String = "") -> String {
        return self.map { $0.rawValue }.joined(separator: separator)
    }
}
