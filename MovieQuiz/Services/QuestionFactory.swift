//
// swiftlint: disable all
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Baev on 26/8/22.
//

import Foundation


final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    weak var delegate: QuestionFactoryDelegate?
    
    init(
        moviesLoader: MoviesLoading,
        delegate: QuestionFactoryDelegate? = nil
    ) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную

                if self.movies.isEmpty {
                    let errorMessage = mostPopularMovies.errorMessage.isEmpty ? "No movies loaded" : mostPopularMovies.errorMessage

                    let error = NSError(
                        domain: "api",
                        code: 42,
                        userInfo: [
                            NSLocalizedDescriptionKey: errorMessage
                        ]
                    )

                    DispatchQueue.main.async {
                        self.delegate?.didFailToLoadData(with: error)
                    }
                }

                DispatchQueue.main.async {
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: error)
                } // сообщаем об ошибке нашему MovieQuizViewController
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                let error = NSError(
                    domain: "api",
                    code: 42,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Failed to load image"
                    ]
                )

                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: error)
                }

                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
