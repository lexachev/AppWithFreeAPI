//
//  AnimeFactAPI.swift
//  AppWithFreeAPI
//
//  Created by Алексей Каллистов on 04.04.2022.
//

import Foundation

final class AnimeFactAPI {
    static let shared = AnimeFactAPI()
    
    struct Constants {
        static let animeFactUrl = "https://anime-facts-rest-api.herokuapp.com/api/v1"
    }
    
    private init() {}
    
    public func getAnimeList(completion: @escaping(Result<[Anime], Error>) -> Void) {
        guard let url = URL(string: Constants.animeFactUrl) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(ResponseAnims.self, from: data)
                    print("Anims: \(result.data.count)")
                    completion(.success(result.data))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    public func getAnimeFacts(animeName: String, completion: @escaping(Result<[Fact], Error>) -> Void) {
        guard let url = URL(string: Constants.animeFactUrl + "/\(animeName)") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(ResponseFacts.self, from: data)
                    print("Facts: \(result.data.count)")
                    completion(.success(result.data))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}


// Models

struct ResponseAnims: Codable {
    let data: [Anime]
}

struct Anime: Codable {
    let anime_id: Int
    let anime_name: String
    let anime_img: String?
}

struct ResponseFacts: Codable {
    let data: [Fact]
}

struct Fact: Codable {
    let fact_id: Int
    let fact: String
}

