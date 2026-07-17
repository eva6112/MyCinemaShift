import Foundation

//менеджер сети
class NetworkManager {
    //синглтон - единственный экземпляр класса
    static let shared = NetworkManager()
    private let baseURL = "https://juniorsbootcamp.ru/api/cinema"
    
    private init() {}
    
    //метод загрузки списка фильмов
    func fetchFilms(completion: @escaping (Result<[Film], Error>) -> Void) {
        let urlString = "\(baseURL)/films"
        //декодируем в филмсРеспонс
        performRequest(with: urlString, decodingType: FilmsResponse.self) { result in
            switch result {
            case .success(let response):
                //достаем массив films
                completion(.success(response.films))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchFilmDetails(id: String, completion: @escaping (Result<Film, Error>) -> Void) {
        let urlString = "\(baseURL)/film/\(id)"
        performRequest(with: urlString, decodingType: FilmResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.film))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchSchedule(id: String, completion: @escaping (Result<[Schedule], Error>) -> Void) {
        let urlString = "\(baseURL)/film/\(id)/schedule"
        performRequest(with: urlString, decodingType: ScheduleResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.schedules ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //метод для выполнения сетевого запроса
    private func performRequest<T: Codable>(with urlString: String, decodingType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        //создаем задачу для загрузки данных
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                //ошибка передается в интерфейс в главном потоке
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            //точно ли пришли данные
            guard let data = data else { return }
            
            do {
                let decodedData = try JSONDecoder().decode(decodingType, from: data)
                DispatchQueue.main.async { completion(.success(decodedData)) }
                
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
            
        }.resume()
    }
}
