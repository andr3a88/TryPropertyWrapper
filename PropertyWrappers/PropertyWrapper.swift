//
//  PropertyWrapper.swift
//  PropertyWrappers
//
//  Created by Andrea Stevanato on 08/10/2019.
//  Copyright © 2019 Andrea Stevanato. All rights reserved.
//

import Foundation

/// A list of property wrappers

/// Clamping a numerical value
@propertyWrapper
struct Clamping<Value: Comparable> {
    
    var value: Value
    let range: ClosedRange<Value>
    
    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        precondition(range.contains(wrappedValue))
        self.value = wrappedValue
        self.range = range
    }
    
    var wrappedValue: Value {
        get { value }
        set { value = min(max(range.lowerBound, newValue), range.upperBound) }
    }
}


/// Wrap UserDefaults
@propertyWrapper
struct Setting<T> {
    
    let key: String
    let defaultValue: T
    let userDefaults: UserDefaults
    
    init(_ key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
    
    var wrappedValue: T {
        get {
            return userDefaults.object(forKey: key) as? T ?? defaultValue
        }
        set {
            userDefaults.set(newValue, forKey: key)
        }
    }
}

/// Perform trim on string
@propertyWrapper
struct Trimmed {
    
    private(set) var value: String = ""
    
    var wrappedValue: String {
        get { value }
        set { value = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
}

/// Perform a GET request using ULRSession
typealias Service<Response> = (_ completionHandler: @escaping (Result<Response, Error>) -> Void) -> ()
@propertyWrapper
struct GET {
    private var url: URL
    init(url: String) {
        self.url = URL(string: url)!
    }
    var wrappedValue: Service<String> {
        get {
            return { completionHandler in
                let task = URLSession.shared.dataTask(with: self.url) { (data, response, error) in
                    guard error == nil else {
                        completionHandler(.failure(error!)); return
                    }
                    let string = String(data: data!, encoding: .utf8)!
                    completionHandler(.success(string))
                }
                task.resume()
            }
        }
    }
}
