//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Никита Пономарев on 13.03.2025.
//


import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizProtocol {
    func show(quiz step: QuizStepViewModel) {
        
    }
    func showAnswerResult(isCorrect: Bool){
        
    }
    func showQuizResults() {
        
    }
    func requestNextQuestion() {
        
    }
    func restartQuiz() {
        
    }
    func showAlert(with alertModel: AlertModel) {
        
    }
    func showNetworkError(message: String) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
         XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
