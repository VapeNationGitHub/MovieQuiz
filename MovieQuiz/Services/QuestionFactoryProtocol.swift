import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
    var questionsAmount: Int { get }
    var questionsCount: Int { get }
}
