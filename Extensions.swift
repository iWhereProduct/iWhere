//
//  Extensions.swift
//  IWHERE
//
//  Created by Михаил on 23.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension Date {
    /**
     Get current date in format: "YYYY.MM.DD HH:MM".
     - Returns: Current date as String.
     */
    public func getCurrentDate() -> String{
        let date = Date()
        let calendar = Calendar.current
        let year: String = {
            return String(calendar.component(.year, from: date))
        }()
        let month: String = {
            if String(calendar.component(.month, from: date)).count < 2 {
                return "0\(calendar.component(.month, from: date))"
            }
            else {
                return String(calendar.component(.month, from: date))
            }
        }()
        let day: String = {
            if String(calendar.component(.day, from: date)).count < 2 {
                return "0\(calendar.component(.day, from: date))"
            }
            else {
                return String(calendar.component(.day, from: date))
            }
        }()
        let hour: String = {
            if String(calendar.component(.hour, from: date)).count < 2 {
                return "0\(calendar.component(.hour, from: date))"
            }
            else {
                return String(calendar.component(.hour, from: date))
            }
        }()
        
        let minute: String = {
            if String(calendar.component(.minute, from: date)).count < 2 {
                return "0\(calendar.component(.minute, from: date))"
            }
            else {
                return String(calendar.component(.minute, from: date))
            }
        }()
        
        let currentDate = year + "." + month + "." + day + " " + hour + ":" + minute
        return currentDate
    }
    /**
     Convert date and return it as String in format: "YYYY.MM.DD HH:MM".
     - Returns: Converted date as String.
     */
    public func convertDate () -> String{
        let timezone: Int = TimeZone.current.secondsFromGMT()
        let dateString = String(describing: self)
        var dateStringArray = dateString.components(separatedBy: " ")
        dateStringArray.removeLast()
        var newDateAray = dateStringArray[0].map {
            $0 == "-" ? "." : $0
        }
        var timeArray = dateStringArray[1].components(separatedBy: ":")
        timeArray.removeLast()
        timeArray[0] = String(describing: Int(timeArray[0])! + timezone / 3600)
        newDateAray = newDateAray + " " + timeArray[0] + ":" + timeArray[1]
        return String(newDateAray)
    }
}

extension UIColor {
    /**
     red: 151, green: 151, blue: 151, alpha: 1
     */
    
    public class var mainGray: UIColor{
        get {
            return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        }
    }
    /**
     red: 234, green: 234, blue: 234, alpha: 1
     */
    public class var secondaryGray: UIColor {
        get {
            return UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
        }
    }
}

extension UIImage {
    
    public enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    public func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
    public func resizeCurrentImage(size: CGSize) -> UIImage?{
        let image = self
        let newSize = CGSize(width: size.width, height: size.height)
        
        let newRect = CGRect(origin: CGPoint.init(x: 0, y: 0), size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: newRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    /**
     Add string at the center of image
     - Parameters:
        - string: String that will be added at center of image
     - Returns: Image with the string at the center
     */
    
    func addStringAtCenterOfCurrentImage(string: NSString?, colorOfString color: UIColor) -> UIImage?{
        let image = self
        let textColor = color
        let textFont = UIFont(name: "Helvetica Neue", size: 20)
        let textFontAttributes = [NSAttributedStringKey.font: textFont!, NSAttributedStringKey.foregroundColor: textColor]
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        let textBounds = string?.boundingRect(with: CGSize(width: image.size.width, height: image.size.height), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        string?.draw(at: CGPoint(x: (image.size.width - textBounds!.width) / 2, y: (image.size.height - textBounds!.height) / 2), withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension String {
    /**
     Convert string corrdinates in format "latitude-longitude" in CLLocation
     Example 12.33-41.55
     - Returns: CLLocationCoordinate2D with init(latitude:, longitude:)
     */
    
    func covertStringCoordsToCLLoacationCordinate2D() -> CLLocationCoordinate2D? {
        let separatedString = self.components(separatedBy: "-")
        if let latitude = Double(separatedString[0]), let longitude = Double(separatedString[1]){
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        }
        return nil
    }
}

extension UIResponder {
    
    func next<T: UIResponder>(_ type: T.Type) -> T? {
        return next as? T ?? next?.next(type)
    }
}

extension UITableViewCell {
    
    var tableView: UITableView? {
        return next(UITableView.self)
    }
    
    var indexPath: IndexPath? {
        return tableView?.indexPath(for: self)
    }
}
