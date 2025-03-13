//
//  MovieQuizProtocol.swift
//  MovieQuiz
//
//  Created by Никита Пономарев on 13.03.2025.
//

import UIKit

protocol MovieQuizProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAnswerResult(isCorrect: Bool)
    func showQuizResults()
    func requestNextQuestion()
    func restartQuiz()
    func showAlert(with alertModel: AlertModel)
    func showNetworkError(message: String) // Добавьте этот метод
}
