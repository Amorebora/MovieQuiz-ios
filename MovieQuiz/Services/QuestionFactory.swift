//
// swiftlint: disable all
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Baev on 26/8/22.
//

import Foundation


final class QuestionFactory: QuestionFactoryProtocol {
 /*   private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true), //  Настоящий рейтинг: 8
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true), // Настоящий рейтинг: 9
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),  // Настоящий рейтинг: 9,2
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true), // Настоящий рейтинг: 8,1
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true), // Настоящий рейтинг: 8
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true), //  Настоящий рейтинг: 6,6
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false), // Настоящий рейтинг: 5,8
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false), //  Настоящий рейтинг: 4,3
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false), // Настоящий рейтинг: 5,1
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false)
    ] //  Настоящий рейтинг: 5,8 */
    
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    private let delegate: QuestionFactoryDelegate
    
    init(
        moviesLoader: MoviesLoading,
        delegate: QuestionFactoryDelegate
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
                self.delegate.didLoadDataFromServer() // сообщаем, что данные загрузились
            case .failure(let error):
                self.delegate.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
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
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate.didReceiveNextQuestion(question: question)
            }
        }
    }
}
