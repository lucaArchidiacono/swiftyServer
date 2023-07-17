//
//  FileReader.swift
//  
//
//  Created by Luca Archidiacono on 16.07.23.
//

import NIO

public enum fs {
    static let threadPool: NIOThreadPool = {
        let tp = NIOThreadPool(numberOfThreads: 4)
        tp.start()
        return tp
    }()
    
    static let fileIO = NonBlockingFileIO(threadPool: threadPool)
    
    public static func readFile(_ path: String,
                                eventLoop: EventLoop? = nil,
                                maxSize: Int = 1024 * 1024,
                                _ completion: @escaping (Error?, ByteBuffer?) -> ()) {
        let eventLoop = eventLoop ?? MultiThreadedEventLoopGroup.currentEventLoop ?? loopGroup.next()
        
        func emit(error: Error? = nil, result: ByteBuffer? = nil) {
            if eventLoop.inEventLoop { completion(error, result) }
            else { eventLoop.execute { completion(error, result) } }
        }
        
        threadPool.submit { state in
            assert(state == .active, "unexpected cancellation")
            
            let fileHandle: NIOFileHandle
            do {
                fileHandle = try NIOFileHandle(path: path)
            } catch { return emit(error: error) }
            
            fileIO.read(fileHandle: fileHandle,
                        // TODO: maxSize needs to be fixed
                        byteCount: maxSize,
                        allocator: ByteBufferAllocator(),
                        eventLoop: eventLoop)
            .map { try? fileHandle.close(); emit(result: $0) }
            .whenFailure { try? fileHandle.close(); emit(error: $0) }
        }
    }
}
