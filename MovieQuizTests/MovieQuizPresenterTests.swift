import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerProtocolMock: MovieQuizViewControllerProtocol {
    func buttonsEnabled(_: Bool) {}
    func show(quiz step: QuizStepViewModel) {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerProtocolMock()

        let statisticsService = StatisticServiceImplementation()
        let resultAlertPresenter = ResultAlertPresenter(
            viewController: UIViewController()
        )

        let movieLoader = MoviesLoader()
        let questionFactory = QuestionFactory(moviesLoader: movieLoader)

        let sut = MovieQuizPresenter(
            questionFactory: questionFactory,
            statisticsService: statisticsService,
            resultAlertPresenter: resultAlertPresenter,
            viewController: viewControllerMock
        )

        questionFactory.delegate = sut

        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)

        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
