import UIKit

public enum Color {    

    public static var accent: UIColor {
        return UIColor(named:"accent", in: Bundle.main, compatibleWith: nil) ?? .clear
    }

    public static var blueBold: UIColor {
        return UIColor(named:"blueBold", in: Bundle.main, compatibleWith: nil) ?? .clear
    }

    public static var disable: UIColor {
        return UIColor(named:"grayLight", in: Bundle.main, compatibleWith: nil) ?? .clear
    }
    
    public static var primaryBold: UIColor {
        return UIColor(named:"primaryBold", in: Bundle.main, compatibleWith: nil) ?? .clear
    }

    public static var redBold: UIColor {
        return UIColor(named:"redBold", in: Bundle.main, compatibleWith: nil) ?? .clear
    }
    
    public static var secondaryBold: UIColor {
        return UIColor(named:"secondaryBold", in: Bundle.main, compatibleWith: nil) ?? .clear
    }

    public static var silver: UIColor {
        return UIColor(named:"silver", in: Bundle.main, compatibleWith: nil) ?? .clear
    }

    public static var surface: UIColor {
        return UIColor(named:"surface", in: Bundle.main, compatibleWith: nil) ?? .clear
    }

    public static var txtColor: UIColor {
        return UIColor(named:"txtColor", in: Bundle.main, compatibleWith: nil) ?? .clear
    }
  
    public static var txtDim: UIColor {
        return UIColor(named:"txtDim", in: Bundle.main, compatibleWith: nil) ?? .clear
    }

    public static var txtParagraph: UIColor {
        return UIColor(named:"txtParagraph", in: Bundle.main, compatibleWith: nil) ?? .clear
    }

    public static var txtTitle: UIColor {
        return UIColor(named:"txtTitle", in: Bundle.main, compatibleWith: nil) ?? .clear
    }

    public static var yellowBold: UIColor {
        return UIColor(named:"yellowBold", in: Bundle.main, compatibleWith: nil) ?? .clear
    }
}
