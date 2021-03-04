//
//  CommunicationManager.swift
//  MyPortfolio
//
//  Created by Tamási Móni on 2021. 03. 03..
//

import Foundation

class CommunicationManager {
    static let shared = CommunicationManager()
    
    func downloadCompanyDetails(symbol: String, callback: ((Bool, String?) -> Void)?)
    {
        let url = String(format: Constants.DetailsUrl, symbol, Constants.APIToken)
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) {data, _, error in
            if error == nil && data != nil {
                DataManager.shared.evaluateData(data: data!, symbol: symbol)
                callback?(true, nil)
            } else {
                callback?(false, error?.localizedDescription)
            }
        }
        task.resume()
    }
}
