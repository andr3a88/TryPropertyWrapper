//
//  Utils.swift
//  PropertyWrappers
//
//  Created by Andrea Stevanato on 08/10/2019.
//  Copyright © 2019 Andrea Stevanato. All rights reserved.
//

import Foundation

/// An example of how to use property wrapper
struct AppSettings {
    @Setting("isFirstLaunch", defaultValue: true)
    static var isFirstLaunch: Bool
}

/// @Trimmed is used as a validator for the property
struct Post {
    @Trimmed var title: String
    @Trimmed var body: String
}

/// A Simple api manager
struct APIManager {
    @GET(url: "https://samples.openweathermap.org/data/2.5/weather?id=2172797&appid=b6907d289e10d714a6e88b30761fae22")
    static var getCurrentWeather: Service<String>
}

/// An object to represents a rating from 0 to 5
struct Rating {
    @Clamping(0...5) var value: Double = 0.0
}

struct User: CustomStringConvertible {
        
    @Validate(minLength: 3, maxLength: 20)
    var firstName: String?
    
    @Validate(minLength: 3, maxLength: 20)
    var lastName: String?
    
    @Validate({ $0 != "admin" })
    var username: String?

    @Validate(regex: "^[a-z]{5,10}$")
    var password: String?
    
    var description: String {
        return "\(firstName), \(lastName), \(username), \(password)"
    }
}
