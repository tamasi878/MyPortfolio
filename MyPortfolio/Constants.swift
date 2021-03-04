//
//  Constants.swift
//  MyPortfolio
//
//  Created by Tamási Móni on 2021. 03. 03..
//

import Foundation
import UIKit

class Constants {
    static let ServerUrl = "wss://ws.finnhub.io?token=%@"
    static let APIToken = "c0u8muv48v6qqphture0"
    static let DetailsUrl = "https://finnhub.io/api/v1/stock/profile2?symbol=%@&token=%@"
    
    static let grayColor = UIColor(red: 147.0/255.0, green: 151.0/255.0, blue: 148.0/255.0, alpha: 1.0)
    static let redColor = UIColor(red: 236.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
    static let greenColor = UIColor(red: 82.0/255.0, green: 176.0/255.0, blue: 89.0/255.0, alpha: 1.0)
}
