# A Swifty Server

You might be wondering, "Luca, why does your blog look so plain and simple?". To answer that, we have to go back several years to when [Netscape](https://en.wikipedia.org/wiki/Netscape_(web_browser)) was invented in 1994.

When Netscape was released, it allowed people to communicate over the WorldWideWeb and share their interests using HTML. Most websites, if not all, were just basic plain text. Soon after, Netscape and Microsoft engaged in a browser war, and both companies started releasing new technologies (like CSS by Microsoft and JavaScript by Netscape). While these companies gave us two of the most important languages of the modern age, they also gave us two of the most notorious ones. Nowadays, if you're not using an AdBlocker or Reader Mode while browsing the web, you're bombarded with sideloading, sluggish scrolling, slow loading, and more.

All we really want is to read, learn, or see the specific content we're looking for on a website. But when so much irrelevant data and information are presented to the user, the actual information we were seeking can get lost, or the user may simply leave the website.

So, that's why I decided to keep it simple.

## Why simplicity?

I wanted to move away from fancy frameworks that currently exist and explore if it's possible to set up a webserver as basic and boring as possible, using the greatest language in the world: [Swift](https://www.swift.org/) (I have to say this as an iOS Developer, please don't judge me).

Now, let's see what's out there and how to create a webserver with Swift.

### SwiftNIO

[SwiftNIO](https://github.com/apple/swift-nio) is a cross-platform asynchronous event-driven network application framework for rapid development of maintainable high-performance protocol servers and clients. It's similar to [Netty](https://netty.io/).

In short, its a framework which you can use to develop network applications for server or clients.

Now before we can start using SwiftNIO. For all the iOS beginners. No, this tutorial is not using SwiftUI or UIKit or anything else which is related to iOS development. This is pure Swift, with a little bit of SwiftNIO ;) Or the other way around, who cares.

#### Setup

Let's open the Terminal and type in the following lines to setup a new executable Swift Package:
```
$ swift package init --type executable
```

After this, open the newly created executable Swift project either by using Visual Studio Code or our fellow companion Xcode.

Now go into `Package.swift` and let's add the following content:
```swift
import PackageDescription

let package = Package(
    name: "swiftyServer",
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-nio",
            from: "2.0.0"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "swiftyServer",
            dependencies: [
                .product(
                    name: "NIO",
                    package: "swift-nio"
                ),
                .product(
                    name: "NIOHTTP1",
                    package: "swift-nio"
                ),
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
```

As promised, the following Swift `Package.swift` file does only contain one single dependency and thats `SwiftNIO`.

### Baby steps

Before we can dive into the nitty gritty, we have to have a plan. What is our end goal? What do we want to achieve?
For this project my goal, was to understand what SwiftNIO is, learn its basics and create a poor mans web server with not much content.

Now to achieve this, I also wanted to have a setup where I can easily extend the web servers code by using a coding style which is quite popular in the JavaScript backend world.

What I refer to is, using sort of a routing/middleware pattern similar to [Express.js](https://expressjs.com/).

As you can see the [routing](https://expressjs.com/en/guide/routing.html) in Express.js looks pretty easy and self explanatory:
```javascript
// GET method route
app.get('/', (req, res) => {
  res.send('GET request to the homepage')
})

// POST method route
app.post('/', (req, res) => {
  res.send('POST request to the homepage')
})
```

You have an app/server instance, where you just can call any HTTP Method (`.get`, `.post`, `.put`, etc.) and listen to a specific endpoint.

When someone calls the endpoint using the specific method, its closure/function gets invoked and you can either do some Business Logic and send something fancy back, or do something boring like me and send a plain HTML file.

For the sake of learning lets do the same as I did ;) Lets send a something boring back.

First, we need to create something similar like the Express.js example showcased us. We need to have server/app instance. Therefore lets go and lets create a `Server.swift` file.

Add the following inside the `Server.swift` file:
```swift
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
            // For docker reasons, this needs to be commented out. I couldn't reach my Docker instance when the code contained the following line of code.
            // After that, I safely managed to reach my endpoints.
//            .childChannelOption(ChannelOptions.socketOption(.tcp_nodelay), value: 1)
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
```
Now lets go through each line and let me explain what it does:

```swift
let loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
```
This line creates a `MultiThreadedEventLoopGroup`, which is a group of event loops. Event loops are a fundamental part of SwiftNIO, responsible for executing tasks and handling I/O operations concurrently. The number of threads is set to the number of available CPU cores.

```swift
public final class Server: Router {
```
Here our class is defined as Server and conforms to a Superclass `Router` which we will take a look afterwards.

```swift
func listen(_ port: Int) {
    defer {
        try? loopGroup.syncShutdownGracefully()
    }
```
The listen function is defined, taking a port number as a parameter. This function will be responsible for starting the server and listening on the specified port. The defer block ensures that the loopGroup is gracefully shutdown when the function exits.

```swift
let serverBootstrap = ServerBootstrap(group: loopGroup)
    .serverChannelOption(ChannelOptions.backlog, value: 256)
    .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
```
A ServerBootstrap instance is created, configuring options for the server channel. These options include setting the backlog, which is the maximum number of pending connections, and enabling the reuse of the address.

```swift
.childChannelInitializer { channel in
    channel.pipeline.configureHTTPServerPipeline().flatMap {
        channel.pipeline.addHandler(HTTPHandler(router: self))
    }
}
```
This block sets up the child channel initializer, where a new channel is configured with an HTTP server pipeline. It adds an HTTPHandler to the pipeline, passing in the current instance of the Server class as a router.


```swift
.childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
.childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
```
Additional options for child channels are set, including reusing the address and limiting the maximum number of messages read per event loop iteration.

```swift
do {
    let channel = try serverBootstrap.bind(host: "0.0.0.0", port: port).wait()
    print("Server started and listening on \(channel.localAddress!)")
    try channel.closeFuture.wait()
    print("Server closed")
} catch {
    fatalError("Failed to start server: \(error)")
}
```
Finally, the server is started by calling bind on the serverBootstrap. It binds to the specified host ("0.0.0.0" means it will listen on all available network interfaces) and port. The server's address is printed, and the function waits for the server to close.

This code essentially sets up a SwiftNIO-based HTTP server with the ability to handle incoming HTTP requests, routing them using the provided Router implementation.


### Are we *routing* into the right direction?
Eagle eye people noticed that our `Server` class conforms/inherits `Router` which I did not introduce yet.



### Utilities


