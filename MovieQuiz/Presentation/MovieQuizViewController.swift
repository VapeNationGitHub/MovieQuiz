import Foundation
import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    // переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex: Int = .zero
    // переменная со счётчиком правильных ответов
    private var correctAnswers: Int = .zero
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let alertPresenter = AlertPresenter()
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        /*
         if let firstQuestion = questionFactory.requestNextQuestion() {
         currentQuestion = firstQuestion
         let viewModel = convert(model: firstQuestion)
         show(quiz: viewModel)
         }
         */
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel( // 1
            image: UIImage(named: model.image) ?? UIImage(), // 2
            question: model.text, // 3
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // 4
        return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // метод меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        // метод отображения результата ответа
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.showNextQuestionOrResults()
        }
    }
    
    @IBAction func yesButtonCkick(_ sender: UIButton) {
        //let currentQuestion = questions[currentQuestionIndex]
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        // let currentQuestion = questions[currentQuestionIndex]
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // идём в состояние "Результат квиза"
            showQuizResults()
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
            /*
             if let nextQuestion = questionFactory.requestNextQuestion() {
             currentQuestion = nextQuestion
             let viewModel = convert(model: nextQuestion)
             
             show(quiz: viewModel)
             }
             */
        }
    }
    // Показать алерт
    private func showQuizResults() {
        
        let alertModel = AlertModel(
            title: "Раунд окончен!",
            message: "Вы правильно ответили на \(correctAnswers) из \(questionFactory?.questionsAmount ?? 0) вопросов.",
            buttonText: "Сыграть еще раз",
            completion: { [weak self] in
                self?.restartQuiz()
            }
        )
        alertPresenter.showAlert(from: self, with: alertModel)
        
        
        /*
         let alert = UIAlertController(
         title: "Раунд окончен!",
         message: "Вы правильно ответили на \(correctAnswers) из \(questionsAmount) вопросов.",
         preferredStyle: .alert
         )
         
         let restartAction = UIAlertAction(title: "Сыграть еще раз", style: .default) { [weak self] _ in
         self?.restartQuiz()
         }
         alert.addAction(restartAction)
         present(alert, animated: true)
         */
        
    }
    
    
    
    
    
    // Cброс игры
    private func restartQuiz() {
        // questionFactory.reset() // Сбросить индекс вопросов
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
        /*
         if let firstQuestion = self.questionFactory.requestNextQuestion() {
         self.currentQuestion = firstQuestion
         let viewModel = self.convert(model: firstQuestion)
         
         self.show(quiz: viewModel)
         }
         */
    }
}
