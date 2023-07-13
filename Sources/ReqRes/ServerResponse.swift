//
//  ServerResponse.swift
//  
//
//  Created by Luca Archidiacono on 12.07.23.
//

import NIO
import NIOHTTP1

public class ServerResponse {
    private let headers = HTTPHeaders()
    private let channel: Channel
    private var didWriteHeader = false
    private var didEnd = false
    
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
    
    private func flushHeader() {
        guard !didWriteHeader else { return }
        didWriteHeader = true
        
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: status)
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
}
