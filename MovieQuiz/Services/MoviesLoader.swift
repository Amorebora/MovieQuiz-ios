// swiftlint: disable all
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Baev on 12/9/22.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}


struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://imdb-api.com/en/API/MostPopularMovies/k_o7ds3xds") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        
        networkClient.fetch(
            url: mostPopularMoviesUrl) { result in
                switch result {
                case .failure(let error):
                    handler(.failure(error))
                case .success(let data):
                    let decoder = JSONDecoder()
                    do {
                        let movies = try decoder.decode(
                            MostPopularMovies.self, from: data
                        )
                        handler(.success(movies))
                    } catch {
                        handler(.failure(error))
                    }
                }
            }
    }
}


