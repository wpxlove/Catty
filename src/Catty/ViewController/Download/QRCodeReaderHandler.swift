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

import UIKit
import QRCodeReader
import AudioToolbox
import SDCAlertView
import M13ProgressSuite
import Alamofire

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

struct QRCodeReaderConfig {

    typealias URLParts = (schemes: [String], hosts: [String], path: String, ports: [Int], query: String)
    enum Sound: String {
        case Start = "airdrop_invite.caf"
        case Success = "sms_alert_aurora.caf"
        case Failed = "sms_alert_input.caf"
        static let basePath = "/System/Library/Audio/UISounds/Modern/"
    }

    static let allowedHosts = ["localhost", "192.168.178.24", "catrobat-scratch2.ist.tu-graz.ac.at", "scratch2.catrob.at"]
    static let allowedURL: URLParts = (["http", "https"], QRCodeReaderConfig.allowedHosts, "/download", [80, 443, 8888], "id=")
}

extension QRCodeReaderConfig {
    static func isAllowedDownloadURL(urlString: String) -> Bool {
        func verifyURL(urlString: String) -> Bool {
            if let url = NSURL(string: urlString) {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
            return false
        }
        guard let givenURL = NSURL(string: urlString),
            let host = givenURL.host,
            let path = givenURL.path,
            let query = givenURL.query
            where QRCodeReaderConfig.allowedURL.hosts.contains(host)
                && QRCodeReaderConfig.allowedURL.schemes.contains(givenURL.scheme)
                && verifyURL(urlString)
            else { return false }

        let allowedPorts = QRCodeReaderConfig.allowedURL.ports
        if givenURL.port != nil && !allowedPorts.contains(givenURL.port!.integerValue) {
            return false
        }

        if path != QRCodeReaderConfig.allowedURL.path {
            return false
        }

        if !query.hasPrefix(QRCodeReaderConfig.allowedURL.query) {
            return false
        }

        let splittedQuery = query.characters.split { $0 == "=" }.map(String.init)
        if splittedQuery.count == 2 && splittedQuery[0] == "id" {
            if let _ = Int(splittedQuery[1]) { // check if download ID is integer
                return true
            }
        }
        return false
    }
}

//            let filePath = NSBundle.mainBundle().pathForResource("Tock", ofType: "caf")
//            let fileURL = NSURL(fileURLWithPath: filePath!)
//            var soundID:SystemSoundID = 0
//            AudioServicesCreateSystemSoundID(fileURL, &soundID)
//            AudioServicesPlaySystemSound(soundID)
extension QRCodeReaderConfig.Sound {
    func path() -> String {
        return "\(self.dynamicType.basePath)\(self.rawValue)"
    }
    func play() {
        guard let soundURL = NSURL(string: self.path()) else { return }
        var soundID:SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
}

class CBQRCodeReaderViewController: QRCodeReaderViewController {
    convenience init(metadataObjectTypes: [String], startScanningAtLoad: Bool = true) {
        self.init(cancelButtonTitle: "Cancel", metadataObjectTypes: metadataObjectTypes, startScanningAtLoad: startScanningAtLoad)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("dismissViewController"))
        doneButton.tintColor = UIColor.whiteColor()
        navigationItem.title = klocalizedQRCodeReader
        navigationItem.leftBarButtonItem = doneButton
        var frame = self.view.frame
        frame.origin.x = 0
        frame.origin.y = 200

        let instructionButton = UIButton()
        instructionButton.translatesAutoresizingMaskIntoConstraints = false
        instructionButton.setTitle("Instructions", forState: .Normal)
        instructionButton.setTitleColor(.grayColor(), forState: .Highlighted)
        instructionButton.addTarget(self, action: "cancelAction:", forControlEvents: .TouchUpInside)
        view.addSubview(instructionButton)

        // get cameraView
        print("test")
        view.addSubview(instructionButton)
        view.bringSubviewToFront(instructionButton)
//        super.cameraView.addSubview(textLabel)
//        super.cameraView.bringSubviewToFront(textLabel)
    }
}

class QRCodeReaderHandler: NSObject, QRCodeReaderViewControllerDelegate {

//    var reader: QRCodeReaderViewController {
//        let builder = QRCodeViewControllerBuilder { builder in
//            builder.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
//            builder.showTorchButton = true
//            builder.cancelButtonTitle = klocalizedCancel
//        }
//        return QRCodeReaderViewController(builder: builder)
//    }
    lazy var readerViewController = CBQRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    var viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showQRCodeViewController(animated: Bool = true) {
        readerViewController.delegate = self
        readerViewController.completionBlock = { (result: QRCodeReaderResult?) in
            if let result = result {
                print("Completion with result: \(result.value) of type \(result.metadataType)")
            }
        }
        readerViewController.modalPresentationStyle = .FormSheet

        let newNavigationVC = UINavigationController()
        newNavigationVC.pushViewController(readerViewController, animated: false)
        viewController.presentViewController(newNavigationVC, animated: animated, completion: nil)
    }

    func dismissViewController() {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - QRCodeReader Delegate Methods
    func reader(reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        if QRCodeReaderConfig.isAllowedDownloadURL(result.value) {
            let URLString = result.value
            print("Downloading file from URL: \(URLString) of type \(result.metadataType)")
            QRCodeReaderConfig.Sound.Start.play()
            viewController.dismissViewControllerAnimated(true, completion: {
                let ring = M13ProgressViewRing(frame: CGRectMake(0, 0, 100, 100))
//                ring.primaryColor = UIColor.blueColor()
                let alert = AlertController(
                    title: "Downloading",
                    message: String (format:"%@ (of type %@)", result.value, result.metadataType),
                    preferredStyle: .Alert
                )

                alert.contentView.addSubview(ring)
                if #available(iOS 9.0, *) {
                    ring.centerXAnchor.constraintEqualToAnchor(alert.contentView.centerXAnchor).active = true
                    ring.topAnchor.constraintEqualToAnchor(alert.contentView.topAnchor).active = true
                    ring.bottomAnchor.constraintEqualToAnchor(alert.contentView.bottomAnchor).active = true
                } else {
                    // Fallback on earlier versions
                }
                alert.addAction(AlertAction(title: klocalizedCancel, style: .Default) { action in
                    QRCodeReaderConfig.Sound.Success.play()
                })
                alert.present()

                var localPath: NSURL?
                Alamofire.download(.GET, URLString, destination: { (temporaryURL, response) in
                        localPath = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())temp.zip")
                        //                        let pathComponent = response.suggestedFilename
                        print(localPath)
                        try? NSFileManager.defaultManager().removeItemAtPath(localPath!.path!)
                        return localPath!
                    })
                    .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                        let progress = Float(totalBytesRead)/Float(totalBytesExpectedToRead)
                        dispatch_async(dispatch_get_main_queue()) {
                            print(">>> \(progress*100.0)%")
                            ring.setProgress(CGFloat(progress), animated: true)
                        }
                    }
                    .response { _, _, _, error in
                        if let error = error {
                            print("Failed with error: \(error)")
                        } else {
                            print("Finished Download")
                            dispatch_async(dispatch_get_main_queue()) {
                                ring.setProgress(1.0, animated: false)
                                QRCodeReaderConfig.Sound.Success.play()
                                alert.dismiss(animated: true) {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        let confirmationAlert = AlertController(
                                            title: "Download Finished",
                                            message: "The program has been added to your programs library!",
                                            preferredStyle: .Alert
                                        )
                                        confirmationAlert.addAction(AlertAction(title: "OK", style: .Preferred) {
                                            (action) in
                                            // TODO: perform segue -> open program
                                        })
                                        confirmationAlert.present()
                                    }
                                    // TODO: move file!
                                    guard let localPath = localPath,
                                          let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
                                    else { return }

                                    let data = NSData(contentsOfURL: localPath)
                                    appDelegate.fileManager.unzipAndStore(data, withProgramID:nil, withName: "A1:S2CC")
                                    
                                }
                            }
                        }
                }
//                self?.viewController.presentViewController(alert, animated: true, completion: nil)
            })
            return
        }

        print("Invalid URL given! \(result.value)")
        QRCodeReaderConfig.Sound.Failed.play()
        let alert = UIAlertController(
            title: "!!! INVALID URL !!!",
            message: String (format:"%@ (of type %@)", result.value, result.metadataType),
            preferredStyle: .Alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { [weak self] (action) in
            self?.readerViewController.startScanning()
        }))
        readerViewController.presentViewController(alert, animated: true, completion: nil)
    }

    func readerDidCancel(reader: QRCodeReaderViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }

}
