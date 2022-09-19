//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Baev on 12/9/22.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {                          // 1
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with: Error) // 2
}
