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

@propertyWrapper
struct Validate<Value> {
    
    private var _value: Value?
    private var _lastValid: Value?
    
    fileprivate let _isValid: (Value) -> Bool
    
    let asserts: Bool
    let useLastValid: Bool
    let message: (Value) -> String
    
    init(_ validation: @escaping (Value) -> Bool, asserts: Bool = false, useLastValid: Bool = false, message: @escaping (Value) -> String = { "Invalid - \(String(describing: $0))" }) {
        self._isValid = validation
        self.asserts = asserts
        self.useLastValid = useLastValid
        self.message = message
    }
    
    var wrappedValue: Value? {
        get {
            if !useLastValid {
                return _value
            } else {
                return _value ?? _lastValid
            }
        }
        set {
            if let newValue = newValue, !_isValid(newValue) {
                if asserts {
                    assertionFailure(self.message(newValue))
                }
                _value = nil
            } else {
                _value = newValue
                if useLastValid { _lastValid = newValue }
            }
        }
    }
}

extension Validate where Value: Equatable {
    init(equals otherValue: Value, asserts: Bool = false) {
        self.init({ $0 == otherValue }, asserts: asserts, message: { "Error: \($0) not equals to \(otherValue)" })
    }
    init(notEquals otherValue: Value, asserts: Bool = false) {
        self.init({ $0 != otherValue }, asserts: asserts, message: { "Error: \($0) equals to \(otherValue)" })
    }
}

extension Validate where Value: Comparable {
    init(lessThan otherValue: Value, asserts: Bool = false) {
        self.init({ $0 < otherValue }, asserts: asserts, message: { "Error: \($0) not less than \(otherValue)" })
    }
    init(greaterThan otherValue: Value, asserts: Bool = false) {
        self.init({ $0 > otherValue }, asserts: asserts, message: { "Error: \($0) not greater than \(otherValue)" })
    }
}

extension Validate where Value: Collection {
    init(isEmpty: Bool, asserts: Bool = false) {
        self.init({ isEmpty && $0.isEmpty }, asserts: asserts, message: { "Error: \($0) is not empty" })
    }
}

extension Validate where Value == String {
    init(regex: String, asserts: Bool = false) {
        self.init({ $0.range(of: regex, options: .regularExpression) != nil },
                  asserts: asserts,
                  message: { "Error: \($0) doesn't match regex: \(regex)" })
    }
    init(minLength: UInt = 0, maxLength: UInt = UInt(Int.max), asserts: Bool = false) {
        self.init({ (minLength...maxLength).contains(UInt($0.count)) },
                  asserts: asserts,
                  message: { "Error: \($0) not between \(minLength) and \(maxLength)" })
    }
    init(isBlank: Bool, asserts: Bool = false) {
        self.init({ isBlank && $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty },
                  asserts: asserts,
                  message: { "Error: \($0) \(isBlank ? "is not blank" : "is blank")" })
    }
}

extension Validate where Value: FixedWidthInteger {
    init(min: Value = .min, max: Value = .max, asserts: Bool = false) {
        self.init({ (min...max).contains($0) }, asserts: asserts, message: { "Error: \($0) not between \(min) and \(max)" })
    }
}

extension Validate where Value: Numeric & Comparable {
    init(min: Value, max: Value, asserts: Bool = false) {
        self.init({ (min...max).contains($0) }, asserts: asserts, message: { "Error: \($0) not between \(min) and \(max)" })
    }
}
