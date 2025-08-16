import UIKit

extension UIImageView {

    func load(from urlString: String, placeholder: UIImage? = nil) {
        self.image = placeholder

        if let cachedImage = ImageCache.shared.image(forKey: urlString) {
            self.image = cachedImage
            return
        }

        guard !urlString.isEmpty, let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }

            ImageCache.shared.cacheImage(forKey: urlString, image)

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}

class ImageCache {

    static let shared = ImageCache()

    private let imageCache = NSCache<NSString, UIImage>()

    func cacheImage(forKey key: String, _ image: UIImage) {
        imageCache.setObject(image, forKey: key as NSString)
    }

    func image(forKey key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
}
