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
import CoreBluetooth
@testable import BluetoothHelper
@testable import Pocket_Code


class SelectionManagerMock: SelectionManagerProtocol {
    var check = false
    func checkStart(){
        check = true
    }
    func deviceNotResponding(){
        
    }
    func giveUpConnectionToDevice(){
        
    }
    func deviceFailedConnection(){
        
    }
    func deviceConnected(peripheral:Peripheral){
        
    }
    func updateWhenActive(){
        
    }
}



class BluetoothServiceTests: XCTestCase {
    var mock = ArduinoTestMock()
    var arduinoTest = ArduinoDevice(peripheral: Peripheral(cbPeripheral:PeripheralMock(test: true), advertisements:[String:String](), rssi: 0))
    override func setUp() {
        super.setUp()
        arduinoTest = ArduinoDevice(peripheral: Peripheral(cbPeripheral:PeripheralMock(test: true), advertisements:[String:String](), rssi: 0))
        arduinoTest.firmata = FirmataMock()
        BluetoothService.sharedInstance().arduino = arduinoTest
        BluetoothService.sharedInstance().selectionManager = SelectionManagerMock()
        let userdefaults = NSUserDefaults.standardUserDefaults()
        userdefaults.setObject([NSString](), forKey: "KnownBluetoothDevices")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResetBluetoothDevice() {
        //When
        BluetoothService.sharedInstance().resetBluetoothDevice()
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedBool, false , "Reporting is wrong")
    }
    
    func testPauseBluetoothDevice() {
        //When
        BluetoothService.sharedInstance().pauseBluetoothDevice()
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedBool, false , "Reporting is wrong")
    }
    func testContinueBluetoothDevice() {
        //When
        BluetoothService.sharedInstance().continueBluetoothDevice()
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedBool, true , "Reporting is wrong")
    }
    
    func testUpdateKnownDevices(){
        //Given
        let string:String = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        let id:NSUUID = NSUUID(UUIDString: string)!
        //When
        BluetoothService.sharedInstance().updateKnownDevices(id)
    
        //Then
        if let array = NSUserDefaults.standardUserDefaults().arrayForKey("KnownBluetoothDevices") {
            let testString:String = array[0] as! String
            XCTAssertEqual(testString, string,"Stored Wrong")
        }
    }
    
    func testRemoveKnownDevices(){
        //Given
        var array:[NSString] = [NSString]()
        array.append("test")
        NSUserDefaults.standardUserDefaults().setObject(array, forKey: "KnownBluetoothDevices")
        //When
        BluetoothService.sharedInstance().removeKnownDevices()
        //Then
        if let array1 = NSUserDefaults.standardUserDefaults().arrayForKey("KnownBluetoothDevices") {
            XCTAssert(array1.isEmpty, "Removing Devices Wrong")
        }
    }
    
    func testGetSemaphore(){
        //When
        let sema = BluetoothService.sharedInstance().getSemaphore()
        //Then
        XCTAssertNotNil(sema)
    }
    
    func testSetAnalogSemaphore(){
        //Given
        let sema = dispatch_semaphore_create(0)
        //When
        BluetoothService.sharedInstance().setAnalogSemaphore(sema)
        //Then
        if let array:[dispatch_semaphore_t] = BluetoothService.sharedInstance().analogSemaphoreArray {
            XCTAssert(!array.isEmpty,"Semaphore Not added")
        }

    }
    
    func testSetDigitalSemaphore(){
        //Given
        let sema = dispatch_semaphore_create(0)
        //When
        BluetoothService.sharedInstance().setDigitalSemaphore(sema)
        //Then
        if let array:[dispatch_semaphore_t] = BluetoothService.sharedInstance().digitalSemaphoreArray {
            XCTAssert(!array.isEmpty,"Semaphore Not added")
        }
    }
    
    func testGetArduino(){
        //When
        let arduino = BluetoothService.sharedInstance().getSensorArduino()
        //Then
        guard let _ = arduino else {
            XCTAssert(false)
            return
        }
    }
    
    func testGetPhiro(){
        //When
        let phiro = BluetoothService.sharedInstance().getSensorArduino()
        //Then
        guard let _ = phiro else {
            XCTAssert(true)
            return
        }
    }
    
    func testDisconnect(){
        //When
        BluetoothService.sharedInstance().disconnect()
        //Then
        
        XCTAssertNil(BluetoothService.sharedInstance().arduino, "not disconnected")
    }
    
    
    func testStartFirmata(){
        //Given
        arduinoTest.rxCharacteristic = CharacteristicMock(test: true)
        arduinoTest.txCharacteristic = CharacteristicMock(test: true)
        // When
        BluetoothService.sharedInstance().startFirmataDevice(arduinoTest, type: .arduino)
        
        //Then
        if let manager = BluetoothService.sharedInstance().selectionManager as? SelectionManagerMock {
            XCTAssertFalse(manager.check, "Not started")
        } else {
            XCTAssert(true,"Not started")
            XCTAssertTrue(BluetoothService.sharedInstance().startedGame, "Not started")
        }
    }

    
}
