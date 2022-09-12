//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Baev on 5/9/22.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}
