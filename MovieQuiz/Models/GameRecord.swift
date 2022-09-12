// swiftlint: disable all
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Baev on 7/9/22.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
} 
