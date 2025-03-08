import Foundation
import UIKit

// Фабрика вопросов
final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData: Data?
            
            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Ошибка при загрузке изображения")
            }
            
            // Вывод алерт, если изображение не загружено и прерываем функцию
            guard let imageData = imageData else {
                DispatchQueue.main.async {
                    self.showImageLoadErrorAlert()
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    private func showImageLoadErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка загрузки изображения",
            message: "Не удалось загрузить постер фильма. Попробуйте ещё раз.",
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { _ in
            self.requestNextQuestion()
        }
        
        alert.addAction(retryAction)
        
        // Отображаем алерт через делегат
        if let viewController = delegate as? UIViewController {
            viewController.present(alert, animated: true)
        }
    }
    
    private let maxQuestions = 10 // максимальное кол-во вопросов 10
    
    var questionsAmount: Int {
        return min(movies.count, maxQuestions)
    }
    
    var questionsCount: Int {
        return min(movies.count, maxQuestions)
    }
}

/*
 // массив вопросов
 private let questions: [QuizQuestion] = [
 QuizQuestion(
 image: "The Godfather",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "The Dark Knight",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "Kill Bill",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "The Avengers",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "Deadpool",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "The Green Knight",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "Old",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: false),
 QuizQuestion(
 image: "The Ice Age Adventures of Buck Wild",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: false),
 QuizQuestion(
 image: "Tesla",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: false),
 QuizQuestion(
 image: "Vivarium",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: false)
 ]
 
 
 var questionsAmount: Int {
 return questions.count
 }
 
 private var currentIndex = 0
 
 var questionsCount: Int {
 return questions.count
 }
 
 // Сбросить индекс вопросов
 func reset() {
 currentIndex = 0
 }
 
 func requestNextQuestion() {
 guard let index = (0..<questions.count).randomElement() else {
 delegate?.didReceiveNextQuestion(question: nil)
 return
 }
 
 let question = questions[safe: index]
 delegate?.didReceiveNextQuestion(question: question)
 }
 */
