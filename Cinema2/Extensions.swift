import UIKit

//ключ (URL), значение (изображение)
let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    //загрузка по url строке
    func loadImage(from urlString: String) {
        self.image = nil
        //загрузка
        self.backgroundColor = .systemGray6
        self.contentMode = .scaleAspectFill
        //заглушка
        self.tintColor = .systemGray3
        
        //формирование корректного пути
        let fullURLString: String
        if urlString.hasPrefix("http") {
            fullURLString = urlString
        } else {
            let cleanPath = urlString.hasPrefix("/") ? String(urlString.dropFirst()) : urlString
            //базовый url сервера
            fullURLString = "https://juniorsbootcamp.ru/api/\(cleanPath)"
        }
        
        guard let url = URL(string: fullURLString) else {
            setPlaceholder()
            return
        }
        
        //проверка кэша
        if let cachedImage = imageCache.object(forKey: fullURLString as NSString) {
            self.image = cachedImage
            return
        }
        
        //асинхронная загрузка из сети
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Ошибка загрузки картинки: статус \(httpResponse.statusCode), URL: \(fullURLString)")
                self?.setPlaceholder()
                return
            }
            
            if error != nil {
                self?.setPlaceholder()
                return
            }
            
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                self?.setPlaceholder()
                return
            }
            
            imageCache.setObject(downloadedImage, forKey: fullURLString as NSString)
            
            //устанавливаем изображение в главном потоке
            DispatchQueue.main.async {
                self?.image = downloadedImage
                self?.contentMode = .scaleAspectFill
            }
        }.resume()
    }
    
    //установка заглушки при отсутствии файла на сервере
    private func setPlaceholder() {
        DispatchQueue.main.async {
            let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
            self.image = UIImage(systemName: "film", withConfiguration: config)
            self.contentMode = .center
        }
    }
}
