// Copyright © 2024 Jonas Frey. All rights reserved.

import Foundation

protocol Day {
    var input: String { get }
    var testInput: String { get }
    var expectedTestResult: String { get }

    func run(input: String) throws -> String
    func run() throws -> String
    func test() throws -> String
}

extension Day {
    func run() throws -> String {
        try run(input: input)
    }
    
    func test() throws -> String {
        try run(input: testInput)
    }
}
