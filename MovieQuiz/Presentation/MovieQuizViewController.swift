import Foundation
import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // переменная с индексом текущего вопроса, начальное значение 0
    // private var currentQuestionIndex: Int = .zero
    // переменная со счётчиком правильных ответов
    private var correctAnswers: Int = .zero
    //private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private let presenter = MovieQuizPresenter()
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.accessibilityIdentifier = "Poster"
        counterLabel.accessibilityIdentifier = "Index"
        
        activityIndicator.hidesWhenStopped = true // Индикатор загрузки скрывается автоматически
        
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23) ?? UIFont.systemFont(ofSize: 23, weight: .bold)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        presenter.viewController = self
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        hideLoadingIndicator() // Скрываем индикатор после загрузки данных
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        requestNextQuestionWithLoading() // Анимация загрзуки
        //questionFactory?.requestNextQuestion()
    }
    
    // Показать activityIndicator перед загрузкой вопроса
    private func requestNextQuestionWithLoading() {
        activityIndicator.startAnimating() // Показываем индикатор перед загрузкой
        
        DispatchQueue.global().async { [weak self] in
            self?.questionFactory?.requestNextQuestion()
            
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating() // Скрываем индикатор после загрузки вопроса
            }
        }
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        self.presenter.resetQuestionIndex()
        self.correctAnswers = .zero
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                self?.showLoadingIndicator()
                self?.questionFactory?.loadData()
            }
        )
        alertPresenter.showAlert(from: self, with: alertModel)
    }
    
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    /*
     private func convert(model: QuizQuestion) -> QuizStepViewModel {
     return QuizStepViewModel(
     image: UIImage(data: model.image) ?? UIImage(),
     question: model.text,
     questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
     }
     */
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // метод меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
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
    
    @IBAction private func yesButtonCkick(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonCkick()
        
        /*
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
         */
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
        /*
        // let currentQuestion = questions[currentQuestionIndex]
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
         */
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            // идём в состояние "Результат квиза"
            showQuizResults()
        } else {
            presenter.switchToNextQuestion()
            // currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    // Показать алерт
    private func showQuizResults() {
        
        // statisticService.store(correct: correctAnswers, total: questionFactory?.questionsCount ?? 0)
        statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
        let bestGame = statisticService.bestGame
        // let resultText = "Ваш результат: \(correctAnswers)/\(questionFactory?.questionsCount ?? 0)"
        let resultText = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)"
        let gamesCountText = "Количество сыграных квизов: \(statisticService.gamesCount)"
        let bestGameText = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let message = [resultText, gamesCountText, bestGameText, accuracyText].joined(separator: "\n")
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть еще раз",
            completion: { [weak self] in
                self?.restartQuiz()
            }
        )
        self.presenter.resetQuestionIndex()
        alertPresenter.showAlert(from: self, with: alertModel)
    }
    
    // Cброс игры
    private func restartQuiz() {
        // presenter.resetQuestionIndex() = 0
        correctAnswers = .zero
        questionFactory?.requestNextQuestion()
    }
}
