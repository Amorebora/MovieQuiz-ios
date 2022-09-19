import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)

    func highlightImageBorder(isCorrectAnswer: Bool)
    func buttonsEnabled(_: Bool)

    func showLoadingIndicator()
    func hideLoadingIndicator()

    func showNetworkError(message: String)
}


final class MovieQuizPresenter {
    private var gameScore = 0
    private let questionsAmount = 10
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0

    private let questionFactory: QuestionFactoryProtocol
    private let statisticsService: StatisticService
    private let resultAlertPresenter: ResultAlertPresenter

    weak var viewController: MovieQuizViewControllerProtocol?

    init(
        questionFactory: QuestionFactoryProtocol,
        statisticsService: StatisticService,
        resultAlertPresenter: ResultAlertPresenter,
        viewController: MovieQuizViewControllerProtocol? = nil
    ) {
        self.questionFactory = questionFactory
        self.statisticsService = statisticsService
        self.resultAlertPresenter = resultAlertPresenter
        self.viewController = viewController
    }

    func startQuiz() {
        viewController?.showLoadingIndicator()
        questionFactory.loadData()
    }


    private func displayAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.buttonsEnabled(false) // временно отключаем кнопки до появления следующего вопроса

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.0
        ) { [weak self] in
            self?.showNextQuestionOrResults()
            self?.viewController?.buttonsEnabled(true) // включаем кнопки, когда появляется следующий вопрос
        }
    }


    func yesButtonClicked() {
        let isCorrect = checkAnswer(answer: false)
        displayAnswerResult(isCorrect: isCorrect)
    }

    func noButtonClicked() {
        let isCorrect = checkAnswer(answer: true)
        displayAnswerResult(isCorrect: isCorrect)
    }

    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func checkAnswer(answer: Bool) -> Bool {
        guard let currentQuestion = currentQuestion
        else {
            return false
        }

        if answer == currentQuestion.correctAnswer {
            gameScore += 1
            return true
        } else {
            return false
        }
    }

    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            showResults()
        } else {
            switchToNextQuestion()
            // увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий урок
            viewController?.showLoadingIndicator()
            questionFactory.requestNextQuestion()
            // показать следующий вопрос
        }
    }


    private func showResults() {
        print("Пора показать результат")

        statisticsService.store(
            correct: gameScore,
            total: questionsAmount
        )

        let title = gameScore == questionsAmount ? "Вы выиграли!" : "Этот раунд окончен!"


        let totalGames = statisticsService.gamesCount
        let bestGame = statisticsService.bestGame

        let accuracy = statisticsService.totalAccuracy * 100
        let accuracyString = String(format: "%.2f", accuracy)

        let winResult = QuizResultsViewModel(
            title: title,
            text:
                """
                Ваш результат: \(gameScore)/\(questionsAmount)
                Количество сыгранных квизов: \(totalGames)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(accuracyString)%
                """,
            buttonText: "Сыграть еще раз"
        )

        resultAlertPresenter.showResultAlert(result: winResult) { [weak self] in
            self?.restart()
        }
    }

    private func restart() {
        currentQuestionIndex = 0
        gameScore = 0

        viewController?.showLoadingIndicator()
        questionFactory.requestNextQuestion()
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let questionViewModel = convert(model: question)

        DispatchQueue.main.async { [weak viewController] in
            viewController?.hideLoadingIndicator()
            viewController?.show(quiz: questionViewModel)
        }
    }

    func didLoadDataFromServer() {
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with: Error) {
        DispatchQueue.main.async { [weak viewController] in
            viewController?.showNetworkError(
                message: with.localizedDescription
            )
        }
    }
}
