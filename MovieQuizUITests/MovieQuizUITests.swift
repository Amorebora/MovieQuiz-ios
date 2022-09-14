//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Baev on 14/9/22.
//

import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
       app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
   
   func testYesButton() {
       let firstPoster = app.images["Poster"]
       
       app.buttons["Yes"].tap()
       
      sleep(3)
      
       let secondPoster = app.images["Poster"]
       let indexLabel = app.staticTexts["Index"]
       
       
       XCTAssertTrue(indexLabel.label == "2/10")
       XCTAssertFalse(firstPoster == secondPoster)
   }
   
   func testNoButton() {
       let firstPoster = app.images["Poster"]
       
       app.buttons["No"].tap()
       
      sleep(3)
      
       let secondPoster = app.images["Poster"]
       let indexLabel = app.staticTexts["Index"]
       
       
       XCTAssertTrue(indexLabel.label == "2/10")
       XCTAssertFalse(firstPoster == secondPoster)
   }
   
   func testResultAlert() {
       
      for index in 1...9 {
         let indexLabel = app.staticTexts["Index"]
         XCTAssertTrue(indexLabel.label == "\(index)/10")
         
         let firstPoster = app.images["Poster"]
         app.buttons["Yes"].tap()
          
         sleep(5)
         
         let secondPoster = app.images["Poster"]

         XCTAssertFalse(firstPoster == secondPoster)
      }
      
      app.buttons["Yes"].tap()
      sleep(3)
      let indexLabel = app.staticTexts["Index"]
      XCTAssertTrue(indexLabel.label == "10/10")
      
      let alert = app.alerts.firstMatch
      XCTAssertTrue(alert.exists)
      
      let continueButton = alert.buttons["continueGame"]
      XCTAssertEqual(continueButton.label, "Сыграть ещё раз")
      continueButton.tap()
      
      sleep(3)
      
      let newIndexLabel = app.staticTexts["Index"]
      XCTAssertTrue(newIndexLabel.label == "1/10")
   }
}
