//
//  ResourceLoader.swift
//  
//
//  Created by Luca Archidiacono on 18.12.23.
//

import Foundation

struct ResourceLoader {
    enum Resource: String {
        case welcome = "Welcome"
        case swifty = "Swifty"
        case `self` = "Self"
    }

    private let bundle: Bundle = Bundle.module

    func load(_ resource: Resource) -> URL? {
        let url = bundle.url(forResource: resource.rawValue, withExtension: "md")
        guard let url else { return nil } 
        return url
    }
}