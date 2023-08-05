# A Swifty Server

You might be wondering, "Luca, why does your blog look so plain and simple?". To answer that, we have to go back several years to when [Netscape](https://en.wikipedia.org/wiki/Netscape_(web_browser)) was invented in 1994.

When Netscape was released, it allowed people to communicate over the WorldWideWeb and share their interests using HTML. Most websites, if not all, were just basic plain text. Soon after, Netscape and Microsoft engaged in a browser war, and both companies started releasing new technologies (like CSS by Microsoft and JavaScript by Netscape). While these companies gave us two of the most important languages of the modern age, they also gave us two of the most notorious ones. Nowadays, if you're not using an AdBlocker or Reader Mode while browsing the web, you're bombarded with sideloading, sluggish scrolling, slow loading, and more.

All we really want is to read, learn, or see the specific content we're looking for on a website. But when so much irrelevant data and information are presented to the user, the actual information we were seeking can get lost, or the user may simply leave the website.

So, that's why I decided to keep it simple.

## Why simplicity?

I wanted to move away from fancy frameworks that currently exist and explore if it's possible to set up a webserver as basic as possible, using the greatest language in the world: [Swift](https://www.swift.org/) (I have to say this as an iOS Developer, please don't judge me).

Now, let's see what's out there and how to create a webserver with Swift.

### SwiftNIO

[SwiftNIO](https://github.com/apple/swift-nio) is a cross-platform asynchronous event-driven network application framework for rapid development of maintainable high-performance protocol servers and clients. It's similar to [Netty](https://netty.io/).

#### Setup

Let's open the Terminal and type in the following lines to setup a new executable Swift Package:
```
$ swift package init --type executable
```

After this, open 
