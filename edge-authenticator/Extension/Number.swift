import Foundation

extension Int {
    var formattedWithSeparator: String? {
        return Formatter.withSeparator.string(from: NSNumber(value: self))
    }
}
