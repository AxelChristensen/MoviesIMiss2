//
//  TMDBService.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import Foundation
import Observation

@Observable
class TMDBService {
    private let baseURL = "https://api.themoviedb.org/3"
    private var apiKey: String?
    
    enum TMDBError: LocalizedError {
        case noAPIKey
        case invalidURL
        case networkError(Error)
        case decodingError(Error)
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .noAPIKey:
                return "TMDB API key not configured"
            case .invalidURL:
                return "Invalid URL"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from server"
            }
        }
    }
    
    init() {
        loadAPIKey()
    }
    
    private func loadAPIKey() {
        // Try to load from Secrets.plist
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String],
           let key = plist["TMDB_API_KEY"] {
            apiKey = key
        }
    }
    
    func searchMovies(query: String) async throws -> [TMDBMovie] {
        guard let apiKey = apiKey else {
            throw TMDBError.noAPIKey
        }
        
        guard !query.isEmpty else {
            return []
        }
        
        var components = URLComponents(string: "\(baseURL)/search/movie")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query)
        ]
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw TMDBError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let movieResponse = try decoder.decode(TMDBMovieResponse.self, from: data)
            return movieResponse.results
        } catch let error as TMDBError {
            throw error
        } catch let error as DecodingError {
            throw TMDBError.decodingError(error)
        } catch {
            throw TMDBError.networkError(error)
        }
    }
    
    func fetchTopRated(page: Int = 1) async throws -> [TMDBMovie] {
        guard let apiKey = apiKey else {
            throw TMDBError.noAPIKey
        }
        
        var components = URLComponents(string: "\(baseURL)/movie/top_rated")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw TMDBError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let movieResponse = try decoder.decode(TMDBMovieResponse.self, from: data)
            return movieResponse.results
        } catch let error as TMDBError {
            throw error
        } catch let error as DecodingError {
            throw TMDBError.decodingError(error)
        } catch {
            throw TMDBError.networkError(error)
        }
    }
    
    var hasAPIKey: Bool {
        apiKey != nil
    }
    
    // MARK: - Actor/Person Search Methods
    
    func searchPeople(query: String) async throws -> [TMDBPerson] {
        guard let apiKey = apiKey else {
            throw TMDBError.noAPIKey
        }
        
        guard !query.isEmpty else {
            return []
        }
        
        var components = URLComponents(string: "\(baseURL)/search/person")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query)
        ]
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw TMDBError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let personResponse = try decoder.decode(TMDBPersonResponse.self, from: data)
            return personResponse.results
        } catch let error as TMDBError {
            throw error
        } catch let error as DecodingError {
            throw TMDBError.decodingError(error)
        } catch {
            throw TMDBError.networkError(error)
        }
    }
    
    func fetchMoviesByActor(personId: Int, page: Int = 1) async throws -> [TMDBMovie] {
        guard let apiKey = apiKey else {
            throw TMDBError.noAPIKey
        }
        
        var components = URLComponents(string: "\(baseURL)/discover/movie")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "with_cast", value: "\(personId)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    func fetchMovieCredits(movieId: Int) async throws -> TMDBMovieCreditsResponse {
        guard let apiKey = apiKey else {
            throw TMDBError.noAPIKey
        }
        
        var components = URLComponents(string: "\(baseURL)/movie/\(movieId)/credits")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw TMDBError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(TMDBMovieCreditsResponse.self, from: data)
        } catch let error as TMDBError {
            throw error
        } catch let error as DecodingError {
            throw TMDBError.decodingError(error)
        } catch {
            throw TMDBError.networkError(error)
        }
    }
    
    func fetchSimilarMovies(movieId: Int, page: Int = 1) async throws -> [TMDBMovie] {
        guard let apiKey = apiKey else {
            throw TMDBError.noAPIKey
        }
        
        var components = URLComponents(string: "\(baseURL)/movie/\(movieId)/similar")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    func fetchRecommendedMovies(movieId: Int, page: Int = 1) async throws -> [TMDBMovie] {
        guard let apiKey = apiKey else {
            throw TMDBError.noAPIKey
        }
        
        var components = URLComponents(string: "\(baseURL)/movie/\(movieId)/recommendations")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    // MARK: - Additional List Methods
    
    func fetchPopular(page: Int = 1) async throws -> [TMDBMovie] {
        try await fetchMovieList(endpoint: "movie/popular", page: page)
    }
    
    func fetchNowPlaying(page: Int = 1) async throws -> [TMDBMovie] {
        try await fetchMovieList(endpoint: "movie/now_playing", page: page)
    }
    
    func fetchUpcoming(page: Int = 1) async throws -> [TMDBMovie] {
        try await fetchMovieList(endpoint: "movie/upcoming", page: page)
    }
    
    func fetchByGenre(genreId: Int, page: Int = 1) async throws -> [TMDBMovie] {
        guard let apiKey = apiKey else {
            throw TMDBError.noAPIKey
        }
        
        var components = URLComponents(string: "\(baseURL)/discover/movie")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "with_genres", value: "\(genreId)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    func fetchByDecade(startDate: String, endDate: String, genreId: Int? = nil, page: Int = 1) async throws -> [TMDBMovie] {
        guard let apiKey = apiKey else {
            throw TMDBError.noAPIKey
        }
        
        var components = URLComponents(string: "\(baseURL)/discover/movie")
        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "primary_release_date.gte", value: startDate),
            URLQueryItem(name: "primary_release_date.lte", value: endDate),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "vote_count.gte", value: "50") // Filter out obscure movies
        ]
        
        if let genreId = genreId {
            queryItems.append(URLQueryItem(name: "with_genres", value: "\(genreId)"))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    // MARK: - Helper Methods
    
    private func fetchMovieList(endpoint: String, page: Int) async throws -> [TMDBMovie] {
        guard let apiKey = apiKey else {
            throw TMDBError.noAPIKey
        }
        
        var components = URLComponents(string: "\(baseURL)/\(endpoint)")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    private func performRequest(url: URL) async throws -> [TMDBMovie] {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw TMDBError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let movieResponse = try decoder.decode(TMDBMovieResponse.self, from: data)
            return movieResponse.results
        } catch let error as TMDBError {
            throw error
        } catch let error as DecodingError {
            throw TMDBError.decodingError(error)
        } catch {
            throw TMDBError.networkError(error)
        }
    }
}
