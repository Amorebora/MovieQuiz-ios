// my project
// swiftlint: disable all

import UIKit

final class MovieQuizViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var questionNumber: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!

    // MARK: - Properties

    private var presenter: MovieQuizPresenter! = nil

    // MARK: - Lifecycle

    private func configurePresenter() {
        let statisticsService = StatisticServiceImplementation()
        let resultAlertPresenter = ResultAlertPresenter(
            viewController: self
        )

        let movieLoader = MoviesLoader()
        let questionFactory = QuestionFactory(moviesLoader: movieLoader)

        presenter = MovieQuizPresenter(
            questionFactory: questionFactory,
            statisticsService: statisticsService,
            resultAlertPresenter: resultAlertPresenter
        )

        questionFactory.delegate = presenter
        presenter.viewController = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePresenter()

        imageView.layer.cornerRadius = 20

        presenter.startQuiz()
    }
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

}

// MARK: - Passive View Logic

extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        let tryAgainAction = UIAlertAction(
            title: "Try again",
            style: .default
        ) { [weak presenter] _ in
            presenter?.startQuiz()
        }
        
        alertController.addAction(tryAgainAction)
        
        present(alertController, animated: true)
    }
    


    func show(quiz step: QuizStepViewModel) { // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        questionLabel.text = step.question
        questionNumber.text = step.questionNumber
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        let greenColor = UIColor(named: "green") ?? .green
        let redColor = UIColor(named: "red") ?? .red
        let borderColor = isCorrectAnswer ? greenColor : redColor

        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = borderColor.cgColor // делаем рамку зеленой
    }

    func buttonsEnabled(_ state: Bool) { //определяем состояние кнопок
        if state {
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        } else {
            self.yesButton.isEnabled = false
            self.noButton.isEnabled = false
        }
    }
}

