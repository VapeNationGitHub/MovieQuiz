import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    var questionsAmount: Int { get }
    var questionsCount: Int { get }
}
