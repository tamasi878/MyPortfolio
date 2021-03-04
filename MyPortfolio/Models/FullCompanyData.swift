//
//  FullCompanyData.swift
//  MyPortfolio
//
//  Created by Tamási Móni on 2021. 03. 01..
//

import Foundation

class FullCompanyData {
    enum PriceChangeIndicator: Int {
        case noData = 0
        case noFreshData = 1
        case noReferenceData = 2
        case still = 3
        case down = 4
        case up = 5
    }
    
    var companyData: CompanyData? = nil
    var symbol: String = ""
    var currentPrice: Double = 0.0
    var name: String = ""
    var sector: String = ""
    var logoUrl: String = ""
    var exchange: String = ""
    
    func getPriceChangeIndicator() ->PriceChangeIndicator {
        if self.currentPrice == 0.0 {
            if self.companyData != nil && self.companyData!.lastPrice != 0.0 {
                return .noFreshData
            } else {
                return .noData
            }
        } else {
            if self.companyData == nil || self.companyData!.lastPrice == 0.0 {
                return .noReferenceData
            } else {
                if self.companyData!.lastPrice == self.currentPrice {
                    return .still
                }
                if self.companyData!.lastPrice > self.currentPrice {
                    return .down
                }
                if self.companyData!.lastPrice < self.currentPrice {
                    return .up
                }
            }
        }
        return .noData
    }
}
