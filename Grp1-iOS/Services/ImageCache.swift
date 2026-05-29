import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Limit cache size to 50MB (roughly)
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func set(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
    
    func get(for url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
    
    func loadImage(from urlStr: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        if let cached = get(for: urlStr) {
            completion(cached)
            return nil
        }
        
        guard let url = URL(string: urlStr) else {
            completion(nil)
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            self?.set(image, for: urlStr)
            DispatchQueue.main.async { completion(image) }
        }
        task.resume()
        return task
    }
}
