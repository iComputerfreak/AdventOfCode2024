// Copyright © 2024 Jonas Frey. All rights reserved.

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        get {
            guard indices.contains(index) else { return nil }
            return self[index]
        }
        mutating set {
            guard let newValue, indices.contains(index) else { return }
            self[index] = newValue
        }
    }
}
