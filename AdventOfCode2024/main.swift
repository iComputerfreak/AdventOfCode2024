// Copyright © 2024 Jonas Frey. All rights reserved.

let days: [any Day] = [
    Day1Part1(),
    Day1Part2(),
    Day2Part1(),
    Day2Part2()
]

for day in days {
    let name = String(describing: type(of: day))
    do {
        let testResult = try day.test()
        let testStatus = testResult == day.expectedTestResult ? "✅" : "❌"
        print("\(testStatus) \(name) Test result: \(testResult). Expected: \(day.expectedTestResult)")
        let result = try day.run()
        print("\(name) Result: \(result)")
    } catch {
        print("\(name): An error occurred: \(error)")
    }
}
