//
//  PropertyWrappersTests.swift
//  PropertyWrappersTests
//
//  Created by Andrea Stevanato on 08/10/2019.
//  Copyright © 2019 Andrea Stevanato. All rights reserved.
//

import XCTest
@testable import PropertyWrappers

class PropertyWrappersTests: XCTestCase {
    
    func testClampingProperty() {

        var rating = Rating(value: 0.0)
        rating.value = 10.0
        
        XCTAssertEqual(rating.value, 5.0)
        
        rating.value = -10.0
        
        XCTAssertEqual(rating.value, 0.0)
    }
}
