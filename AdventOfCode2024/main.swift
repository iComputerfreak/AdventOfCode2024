// Copyright © 2024 Jonas Frey. All rights reserved.

let day = Day1Part2.self

do {
    let testResult = try day.test()
    print("Test result: \(testResult). Expected: \(day.expectedTestResult)")
    let result = try day.run()
    print("Result: \(result)")
} catch {
    print("An error occurred: \(error)")
}
