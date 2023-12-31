//
//  ServerResponse.swift
//  
//
//  Created by Luca Archidiacono on 12.07.23.
//

import NIO
import NIOHTTP1
import Ink
import Foundation

public class ServerResponse {
    private let channel: Channel
    private var headers = HTTPHeaders()
    private var didWriteHeader = false
    private var didEnd = false
    private let resourceLoader = ResourceLoader()
    
    var status = HTTPResponseStatus.ok
    
    init(channel: Channel) {
        self.channel = channel
    }
    
    func send(_ s: String) {
        flushHeader()
        
        // allocate space/capacity for the bytebuffer based on length of the message
        var buffer = channel.allocator.buffer(capacity: s.count)
        // write the message to the allocated space/capacity for the bytebuffer
        buffer.writeString(s)
        
        let part = HTTPServerResponsePart.body(.byteBuffer(buffer))
        
        // If we would only call `.write()` on the channel, then it does not actually write data out to the socket. To send it to the socket, the channel must be flushed. Therefore we call `.writeAndFlush()`.
        _ = channel.writeAndFlush(part)
        // In case of error we redirect it to our handler.
            .recover(handleError(_:))
        // If everything is fine and no errors occured, we call `.end()`.
            .map(end)
    }
    
    func render(_ resource: ResourceLoader.Resource, _ options: Any? = nil) {
        let res = self
        
        guard let url = resourceLoader.load(resource) else {
            res.status = .notFound
            return res.send("Error: Could not find template -> \(resource.rawValue)")
        }
        
        fs.readFile(url.path) { error, data in
            guard var data = data else {
                res.status = .internalServerError
                return res.send("Error: \(error as Optional)")
            }
            
            data.writeBytes([0])
            
            let inlineCodeModifier = Modifier(target: .inlineCode) { html, markdown in
                return html.replacingOccurrences(of: "<code>", with: "<code id=\"inline-code\">")
            }
            let codeBlockModifier = Modifier(target: .codeBlocks) { html, markdown in 
                return html.replacingOccurrences(of: "<code", with: "<code id=\"code-block\"")
            }
            let parser = MarkdownParser(modifiers: [inlineCodeModifier, codeBlockModifier])
            let dataString = String(buffer: data)
            let body = parser.html(from: dataString)
            let htmlTemplate = HTMLTemplate(title: resource.rawValue, body: body)
            
            res.send(htmlTemplate.render())
        }
    }
    
    private func flushHeader() {
        guard !didWriteHeader else { return }
        didWriteHeader = true

        let httpHeaders = HTTPHeaders([
            ("Content-Type", "text/html"),
            /// HTTP Strict Transport Security (HSTS) header
            ("Strict-Transport-Security", "max-age=63072000"),
            /// X-Content-Type-Options: nosniff
            ("X-Content-Type-Options", "nosniff"),
            /// X-Frame-Options (XFO) header
            /// Only allow my site to frame itself
            ("Content-Security-Policy", "frame-ancestors 'self'"),
            ("X-Frame-Options", "SAMEORIGIN"),
            /// X-XSS-Protection header
            ("X-XSS-Protection", "0"),
        ])
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1),
                                    status: status,
                                    headers: httpHeaders)
        let part = HTTPServerResponsePart.head(head)
        
        _ = channel.writeAndFlush(part)
            .recover(handleError(_:))
    }
    
    private func handleError(_ error: Error) {
        print(error)
        end()
    }
    
    private func end() {
        guard !didEnd else { return }
        didEnd = true
        
        _ = channel.writeAndFlush(HTTPServerResponsePart.end(nil)).map { self.channel.close() }
    }
    
    private subscript(name: String) -> String? {
        set {
            assert(!didWriteHeader, "header is out!")
            if let v = newValue {
                headers.replaceOrAdd(name: name, value: v)
            }
            else {
                headers.remove(name: name)
            }
        }
        get {
            return headers[name].joined(separator: ", ")
        }
    }
}
