import Foundation
import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizProtocol {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var questionFactory: QuestionFactoryProtocol?
    private let alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.accessibilityIdentifier = "Poster"
        counterLabel.accessibilityIdentifier = "Index"
        
        activityIndicator.hidesWhenStopped = true // Индикатор загрузки скрывается автоматически
        
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23) ?? UIFont.systemFont(ofSize: 23, weight: .bold)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        
        imageView.layer.cornerRadius = 20
        
        presenter = MovieQuizPresenter(viewController: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: presenter)
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - MovieQuizProtocol
    
    // метод вывода на экран вопроса, который принимает на выход вью модель вопросо и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // метод меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    // Показать алерт
    func showQuizResults() {
        presenter.showQuizResults(statisticService: statisticService)
    }
    
    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    // Сброс игры
    func restartQuiz() {
        questionFactory?.requestNextQuestion()
    }
    
    func showAlert(with alertModel: AlertModel) {
        alertPresenter.showAlert(from: self, with: alertModel)
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                self?.showLoadingIndicator()
                self?.questionFactory?.loadData()
            }
        )
        showAlert(with: alertModel)
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonCkick(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private Methods
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
}
