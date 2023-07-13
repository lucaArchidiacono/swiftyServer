//
//  HTTPHandler.swift
//  
//
//  Created by Luca Archidiacono on 12.07.23.
//

import NIO
import NIOHTTP1

final class HTTPHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    
    let router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // UNWRAPS the incoming data based on the predefined InboundIn typealias
        let input = unwrapInboundIn(data)
        
        switch input {
        case let .head(header):
            let request = IncomingMessage(header: header)
            let response = ServerResponse(channel: context.channel)
            
            router.handle(request: request, response: response) { (items: Any...) in // the final handler
                // because there is neither middleware configured nor any does any middleware call next we call this closure
                response.status = .notFound // 404 error
                response.send("No middleware handled the request!")
            }
            
        case .body, .end: break
        }
    }
    
    func channelReadComplete(context: ChannelHandlerContext) {
        // We call `.write()` on the channel. That thing does not actually write data out to the socket. To send it to the socket, the channel must be flushed. Which is why we call flush here, after completed with reading.
        context.flush()
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print(error)
        
        context.close(promise: nil)
    }
}
