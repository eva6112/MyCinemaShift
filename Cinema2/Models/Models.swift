import Foundation

//ответ по фильмам

//в джсон и обратно
struct FilmsResponse: Codable {
    let success: Bool?
    let films: [Film]
}

struct FilmResponse: Codable {
    let success: Bool?
    let film: Film
}

struct Film: Codable {
    let id: String
    let name: String
    let description: String?
    let genres: [String]?
    let img: String?
    let actors: [Actor]?
}

struct Actor: Codable {
    let id: String
    let fullName: String
    let photo: String?
}

//ответ с расписанием
struct ScheduleResponse: Codable {
    let success: Bool?
    let schedules: [Schedule]?
}

struct Schedule: Codable {
    let date: String
    let seances: [Seance]
}

struct Seance: Codable {
    let time: String
    let hall: Hall
}

struct Hall: Codable {
    let name: String
}

