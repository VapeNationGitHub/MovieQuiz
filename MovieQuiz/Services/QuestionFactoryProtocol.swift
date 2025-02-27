import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    var questionsAmount: Int { get }
}
