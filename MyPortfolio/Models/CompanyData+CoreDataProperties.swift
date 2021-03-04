//
//  CompanyData+CoreDataProperties.swift
//  MyPortfolio
//
//  Created by Tamási Móni on 2021. 03. 01..
//
//

import Foundation
import CoreData


extension CompanyData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CompanyData> {
        return NSFetchRequest<CompanyData>(entityName: "CompanyData")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var lastPrice: Double

}

extension CompanyData : Identifiable {
}
