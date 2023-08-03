//
//  Server.swift
//  
//
//  Created by Luca Archidiacono on 12.07.23.
//

import NIO
import NIOHTTP1

let loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

public final class Server: Router {
    
    func listen(_ port: Int) {
        defer {
            try? loopGroup.syncShutdownGracefully()
        }
        
        let serverBootstrap = ServerBootstrap(group: loopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandler(HTTPHandler(router: self))
                }
            }
            .childChannelOption(ChannelOptions.socketOption(.tcp_nodelay), value: 1)
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        
        do {
            let channel = try serverBootstrap.bind(host: "0.0.0.0", port: port).wait()
            print("Server started and listening on \(channel.localAddress!)")
            try channel.closeFuture.wait()
            print("Server closed")
        } catch {
            fatalError("Failed to start server: \(error)")
        }
    }
}
