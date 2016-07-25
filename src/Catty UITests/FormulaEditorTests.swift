/**
 *  Copyright (C) 2010-2016 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import XCTest

class FormulaEditorTests: XCTestCase, UITestProtocol {
    
    override func setUp() {
        super.setUp()
       
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        dismissWelcomeScreenIfShown()
        
        restoreDefaultProgram()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEnterNumbers() {
        enterMyFirstProgramBackgroundScriptsFormulaEditorView();
        let app = XCUIApplication()
        
        XCTAssertTrue(app.collectionViews.buttons[" 1 "].exists, "Formula '1' should be visible but isn't!")
        app.collectionViews.buttons[" 1 "].tap()
        
        let formulaTextField = app.textViews["FormulaEditorTextField"]
        for numberToTest in 0...9
        {
            let numberAsString = String(numberToTest)
            XCTAssertTrue(formulaTextField.exists, "Textfield should be visible but isn't!")
            formulaTextField.tap()
            
            XCTAssertTrue(formulaTextField.buttons["del active"].exists, "Delete in textfield should be visible but isn't!")
            formulaTextField.buttons["del active"].tap()
            
            XCTAssertTrue(app.buttons[numberAsString].exists, "Button " + numberAsString + "does not exist here!")
            app.buttons[numberAsString].tap();
            XCTAssertTrue(formulaTextField.exists, "Text field doesn't exist!")
            XCTAssertEqual(numberAsString, formulaTextField.value as? String, "String in textfield is wrong!")
        }
    }
    
    
    func testEnterValidExpression() {
        enterMyFirstProgramBackgroundScriptsFormulaEditorView();
        let app = XCUIApplication()
        
        let validTestString = "-(1+2+3+4+(-5+6)+(7+8)+9)/(-(1x2x3x4x5x6x7x8x9)-10)"

        XCTAssertTrue(app.collectionViews.buttons[" 1 "].exists, "Formula containing 1 should be visible")
        app.collectionViews.buttons[" 1 "].tap()
        
        let formulaTextField = app.textViews["FormulaEditorTextField"]
        
        XCTAssertTrue(formulaTextField.exists, "Textfield is not visible!")
        formulaTextField.tap()
        XCTAssertTrue(formulaTextField.buttons["del active"].exists, "Delete Button is not visible!")
        formulaTextField.buttons["del active"].tap()
        for buttonString in validTestString.characters
        {
            XCTAssertTrue(app.buttons[String(buttonString)].exists, String(buttonString) + " should be visible but isn't!")
            app.buttons[String(buttonString)].tap()
        }
        XCTAssertTrue(app.buttons["Done"].exists, "Done Button does not exist")
        app.buttons["Done"].tap()
        //check if done worked...
        XCTAssertTrue(app.navigationBars["Scripts"].exists)
    }
    
    func testEnterInvalidExpression() {
        enterMyFirstProgramBackgroundScriptsFormulaEditorView();
        let app = XCUIApplication()
        
        let invalidTestString0 = "(1-+2)"
        let invalidTestString1 = "++1"
        let invalidTestString2 = "-"
        let invalidTestString3 = "x"
        let invalidTestString4 = "/"
        let invalidTestString5 = "8+9x9/"
        let invalidTestString6 = "x8"
        
        
        let invalidTestStrings = [invalidTestString0, invalidTestString1, invalidTestString2, invalidTestString3, invalidTestString4, invalidTestString5, invalidTestString6]
        
        XCTAssertTrue(app.collectionViews.buttons[" 1 "].exists, "Formula containing 1 should be visible")
        app.collectionViews.buttons[" 1 "].tap()
        
        for invalidTestString in invalidTestStrings
        {
            let formulaTextField = app.textViews["FormulaEditorTextField"]
            XCTAssertTrue(formulaTextField.exists, "Textfield is not visible!")
            formulaTextField.tap()
            XCTAssertTrue(formulaTextField.buttons["del active"].exists, "Delete Button is not visible!")
            formulaTextField.buttons["del active"].tap()
            for buttonString in invalidTestString.characters
            {
                app.buttons[String(buttonString)].tap()
            }
            XCTAssertTrue(app.buttons["Done"].exists, "Done Button does not exist!")
            app.buttons["Done"].tap()
            //check if done worked...
            XCTAssertTrue(app.buttons["Done"].exists, "Done worked but should not!")
        }
    }
    
    
    func testMathMode() {

        let app = XCUIApplication()
        let mathButton = app.childrenMatchingType(.Window).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button)["Math"]
        let button = "sin"
        let functionsToTest = ["sin":       "sin( 0 )",
                               "cos":       "cos( 0 )",
                               "tan":       "tan( 0 )",
                               "ln":        "ln( 0 )",
                               "log":       "log( 0 )",
                               "pi":        "pi",
                               "sqrt":      "sqrt( 0 )",
                               "abs":       "abs( 0 )",
                               "max":       "max( 0 , 1 )",
                               "min":       "min( 0 , 1 )",
                               "arcsin":    "arcsin( 0 )",
                               "arccos":    "arccos( 0 )",
                               "arctan":    "arctan( 0 )",
                               "round":     "round( 0 )",
                               "mod":       "mod( 1 , 1 )",
                               "rand":      "rand( 0 , 1 )",
                               "exp":       "exp( 1 )",
                               "ceil":      "ceil( 0 )",
                               "floor":     "floor( 0 )",
                               "letter":    "letter( 1 , 'hello world' )",
                               "length":    "length( 'hello world' )",
                               "join":      "join( 'hello' , ' world' )"]
        
        formulaEditorEnterAllPossibilitiesUsingSectionElement(mathButton,
                                                              functionsToTest: functionsToTest,
                                                              visibleButtonInScrollViewIdentifier: button)
    }
    
    func testLogicMode(){
        let app = XCUIApplication()
        let logicButton = app.childrenMatchingType(.Window).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button)["Logic"]
        
        let button = "="
        let functionsToTest = ["≠":     "≠",
                               "=":     "=",
                               "<":     "<",
                               "≤":     "≤",
                               ">":     ">",
                               "≥":     "≥",
                               "and":   "and",
                               "or":    "or",
                               "not":   "not",
                               "true":  "true",
                               "false": "false"]
    
        formulaEditorEnterAllPossibilitiesUsingSectionElement(logicButton,
                                                              functionsToTest: functionsToTest,
                                                              visibleButtonInScrollViewIdentifier: button)
    }

    func testObjectMode(){
        let app = XCUIApplication()
        let objectButton = app.childrenMatchingType(.Window).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button)["Object"]
    
        let button = "pos_x"
        let functionsToTest = ["pos_x":         "pos_x",
                               "pos_y":         "pos_y",
                               "transparency":  "transparency",
                               "brightness":    "brightness",
                               "size":          "size",
                               "direction":     "direction",
                               "layer":         "layer"]
        
        formulaEditorEnterAllPossibilitiesUsingSectionElement(objectButton,
                                                              functionsToTest: functionsToTest,
                                                              visibleButtonInScrollViewIdentifier: button)
    }
    
    func testSensorMode(){
        let app = XCUIApplication()
        let sensorButton = app.childrenMatchingType(.Window).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button)["Sensors"]
        
        let button = "pos_x"
        let functionsToTest = ["acceleration_x":    "acceleration_x",
                               "acceleration_y":    "acceleration_y",
                               "acceleration_z":    "acceleration_z",
                               "compass":           "compass",
                               "inclination_x":     "inclination_x",
                               "inclination_y":     "inclination_y",
                               "loudness":          "loudness"]
        
        formulaEditorEnterAllPossibilitiesUsingSectionElement(sensorButton,
                                                              functionsToTest: functionsToTest,
                                                              visibleButtonInScrollViewIdentifier: button)
    }
}

