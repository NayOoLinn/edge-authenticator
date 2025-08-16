import UIKit

public enum Font: String, CaseIterable {
    case black = "-Black"
    case bold = "-Bold"
    case extraBold = "-ExtraBold"
    case extraLight = "-ExtraLight"
    case light = "-Light"
    case medium = "-Medium"
    case regular = "-Regular"
    case semiBold = "-SemiBold"
    case thin = "-Thin"

    static let fontFamily = "Poppins"
    static let allNames: [String] = Font.allCases.map { fontFamily + $0.rawValue }

    public func of(size: CGFloat) -> UIFont {
        return UIFont(name: Font.fontFamily + self.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
