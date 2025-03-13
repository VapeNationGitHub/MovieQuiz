import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizProtocol?
    
    init(viewController: MovieQuizProtocol) {
        self.viewController = viewController
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = .zero
        correctAnswers = .zero
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        handleAnswer(givenAnswer: givenAnswer, correctAnswer: currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        handleAnswer(givenAnswer: givenAnswer, correctAnswer: currentQuestion.correctAnswer)
    }
    
    private func handleAnswer(givenAnswer: Bool, correctAnswer: Bool) {
        let isCorrect = givenAnswer == correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        
        viewController?.showAnswerResult(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            viewController?.showQuizResults()
        } else {
            switchToNextQuestion()
            viewController?.requestNextQuestion()
        }
    }
    
    // алерт
    func showQuizResults(statisticService: StatisticServiceProtocol) {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let bestGame = statisticService.bestGame
        let resultText = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let gamesCountText = "Количество сыграных квизов: \(statisticService.gamesCount)"
        let bestGameText = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let message = [resultText, gamesCountText, bestGameText, accuracyText].joined(separator: "\n")
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть еще раз",
            completion: { [weak self] in
                self?.resetQuestionIndex()
                self?.viewController?.restartQuiz()
            }
        )
        viewController?.showAlert(with: alertModel)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}
