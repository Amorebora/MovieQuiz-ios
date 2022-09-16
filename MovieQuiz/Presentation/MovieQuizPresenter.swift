import UIKit

final class MovieQuizPresenter {
    private var gameScore = 0
    let questionsAmount = 10
    private var currentQuestionIndex = 0

    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    func checkAnswer(answer: Bool) -> Bool {
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

    func noButtonClicked() {
        let isCorrect = checkAnswer(answer: true)
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }

    func yesButtonClicked() {
        let isCorrect = checkAnswer(answer: false)
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }
}
