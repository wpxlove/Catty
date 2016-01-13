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


struct QRCodeReaderConfig {

    typealias URLParts = (schemes: [String], hosts: [String], path: String, ports: [Int], query: String)

    static let allowedHosts = ["catrobat-scratch2.ist.tu-graz.ac.at", "scratch2.catrob.at"]
    static let allowedURL: URLParts = (["http", "https"], QRCodeReaderConfig.allowedHosts, "/downloads", [80, 443], "file=")

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
            let query = givenURL.query,
            let port = givenURL.port
            where QRCodeReaderConfig.allowedURL.hosts.contains(host)
                && QRCodeReaderConfig.allowedURL.schemes.contains(givenURL.scheme)
                && QRCodeReaderConfig.allowedURL.ports.contains(port.integerValue)
                && verifyURL(urlString)
            else { return false }

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

class QRCodeReaderHandlerViewController: UIViewController, QRCodeReaderViewControllerDelegate {

//    var reader: QRCodeReaderViewController {
//        let builder = QRCodeViewControllerBuilder { builder in
//            builder.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
//            builder.showTorchButton = true
//            builder.cancelButtonTitle = klocalizedCancel
//        }
//        return QRCodeReaderViewController(builder: builder)
//    }
    lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()

        navigationItem.title = klocalizedQRCodeReader

        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("dismissViewController"))
//        doneButton.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = doneButton
        scanAction(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func dismissViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func scanAction(sender: AnyObject) {
        reader.delegate = self
        reader.completionBlock = { (result: QRCodeReaderResult?) in
            if let result = result {
                print("Completion with result: \(result.value) of type \(result.metadataType)")
            }
        }
        reader.modalPresentationStyle = .FormSheet
        presentViewController(reader, animated: true, completion: nil)
    }

    // MARK: - QRCodeReader Delegate Methods
    func reader(reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        if QRCodeReaderConfig.isAllowedDownloadURL(result.value) {
            // TODO: download that file!
            print("Downloading file from URL: \(result.value) of type \(result.metadataType)")
            dismissViewControllerAnimated(true, completion: { [weak self] in
                let alert = UIAlertController(
                    title: "Congrats! Valid URL!",
                    message: String (format:"%@ (of type %@)", result.value, result.metadataType),
                    preferredStyle: .Alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self?.presentViewController(alert, animated: true, completion: nil)
            })
            return
        }

        print("Invalid URL given! \(result.value)")
        dismissViewControllerAnimated(true, completion: { [weak self] in
            let alert = UIAlertController(
                title: "!!! INVALID URL !!!",
                message: String (format:"%@ (of type %@)", result.value, result.metadataType),
                preferredStyle: .Alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self?.presentViewController(alert, animated: true, completion: nil)
        })
    }

    func readerDidCancel(reader: QRCodeReaderViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
