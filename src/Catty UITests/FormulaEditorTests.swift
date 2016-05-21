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
        
        app.collectionViews.buttons[" 1 "].tap()
        
        let formulaTextField = app.textViews["FormulaEditorTextField"]
        for numberToTest in 0...9
        {
            let numberAsString = String(numberToTest)
            formulaTextField.tap()
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
        
        let invalidTestStrings = [invalidTestString0, invalidTestString1, invalidTestString2, invalidTestString3, invalidTestString4]
        
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
}
