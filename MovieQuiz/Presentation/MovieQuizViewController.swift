// my project
// swiftlint: disable all

import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        showQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with: Error) {
        showNetworkError(message: with.localizedDescription)
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var questionNumber: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!

    // MARK: - Properties
    
    private var currentQuestionIndex: Int = 0
    private var gamesScore: QuizScores = QuizScores()
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol!
    
    private var currentQuestion: QuizQuestion?
    
    private var resultAlertPresenter: ResultAlertPresenter? = nil

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
        
        imageView.layer.cornerRadius = 20
        questionFactory.loadData()
        
        resultAlertPresenter = ResultAlertPresenter(viewController: self)
    }
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        showAnswerResult(answer: false)
        /* question: questions[currentQuestionIndex]) */
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        showAnswerResult(answer: true)
        /* question: questions[currentQuestionIndex]) */
    }

    // MARK: - Business Logic
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        let tryAgainAction = UIAlertAction(
            title: "Try again",
            style: .default
        ) { _ in
            print("trying again")
        }
        
        alertController.addAction(tryAgainAction)
        
        present(alertController, animated: true)
    }
    
    private func showQuestion(question: QuizQuestion) {
        /// Установили текущий вопрос. Так как у нас квиз начинается с 1го вопроса,
        /// то и берем из массива вопросов 1й элемент


        let questionViewModel = convert(model: question)
        show(quiz: questionViewModel)

    }

    private func show(quiz step: QuizStepViewModel) { // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        questionLabel.text = step.question
        questionNumber.text = step.questionNumber
    }

    private func show(quiz result: QuizResultsViewModel) {
        resultAlertPresenter?.showResultAlert(result: result) { [weak self] in
            self?.restart()
        }
    }

    private func correctAnswerCounter() {
        gamesScore.score += 1
    }


    private func showAnswerResult(answer: Bool) {

        guard let currentQuestion = currentQuestion
        else {
            return
        }

        let isCorrect = (answer == currentQuestion.correctAnswer)
        let greenColor = UIColor(named: "green") ?? .green
        let redColor = UIColor(named: "red") ?? .red
        let borderColor = isCorrect ? greenColor : redColor

    if answer == currentQuestion.correctAnswer {
        gamesScore.score += 1
    } else {}

        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = borderColor.cgColor // делаем рамку зеленой

        buttonsEnabled(is: false) // временно отключаем кнопки до появления следующего вопроса
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
            self?.buttonsEnabled(is: true) //включаем кнопки, когда появляется следующий вопрос
        }
    }

    private func buttonsEnabled(is state: Bool) { //определяем состояние кнопок
        if state {
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        } else {
            self.yesButton.isEnabled = false
            self.noButton.isEnabled = false
        }
    }
    
    private func showResults() {
        print("Пора показать результат")
        gamesScore.itIsRecord() // проверяем рекорд ли это
        
        let title = gamesScore.score == 10 ? "Вы выиграли!" : "Этот раунд окончен!"
        
        let winResult = QuizResultsViewModel (
            title: title,
            text:  """
                        Ваш результат: \(gamesScore.score)/\(questionsAmount)
                        Количество сыгранных квизов: \(gamesScore.gamesPlayed)
                        Рекорд: \(gamesScore.record)/\(questionsAmount) (\(gamesScore.recordTime))
                        Средняя точность: \(gamesScore.accuracyAverage())%
                        """,
            buttonText: "Сыграть еще раз"
        )
        show(quiz: winResult)
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 { // - 1 потому что индекс начинается с 0, а длинна массива — с 1
            showResults()
        } else {
            currentQuestionIndex += 1
            // увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий урок
            questionFactory.requestNextQuestion()
            // показать следующий вопрос
        }
    }

    private func restart() {
        currentQuestionIndex = 0 // Сбросил вопрос на первый
        gamesScore.restartQuiz()
        questionFactory.requestNextQuestion()
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? .remove,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    // Выносим показ окна алерта в отдельную функцию

}

