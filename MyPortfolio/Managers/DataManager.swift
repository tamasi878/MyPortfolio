//
//  DataManager.swift
//  MyPortfolio
//
//  Created by Tamási Móni on 2021. 03. 03..
//

import Foundation
import UIKit
import CoreData

class DataManager {
    static let shared = DataManager()
    
    var hasConnection: Bool = false
    var companies: [FullCompanyData] = [FullCompanyData]()
    
    init() {
        getSavedData()
    }
        
    func subscribeToCompanies() {
        if let json = self.readJsonFile() {
            if let companyList = json["companies"] as? [String] {
                for company in companyList {
                    if (SocketManager.shared.isConnected()) {
                        self.hasConnection = true
                        SocketManager.shared.write(message: "{\"type\":\"subscribe\",\"symbol\":\"\(company)\"}")
                    } else {
                        self.hasConnection = false
                    }
                }
            }
        }
    }
    
    func evaluateMessage(message: String) {
        if let json = self.parseJsonString(jsonString: message) {
            if (json["type"] as? String ?? "") == "trade" {
                if let data = json["data"] as? [[String: Any]] {
                    for index in 0..<data.count {
                        let info = data[index] as [String: Any]
                        let symbol = info["s"] as? String
                        let price = info["p"] as? Double ?? 0.0
                        if symbol != nil {
                            let company = self.companies.filter { comp in
                                return comp.symbol == symbol
                            }
                            if !company.isEmpty {
                                if self.isCompanySaved(symbol: symbol!) {
                                    if company[0].companyData != nil &&
                                        company[0].currentPrice != company[0].companyData!.lastPrice
                                    {
                                        self.updateCompany(symbol: symbol!, lastPrice: company[0].currentPrice)
                                    }
                                } else {
                                    _ = self.saveCompany(symbol: symbol!, lastPrice: company[0].currentPrice)
                                }
                                company[0].currentPrice = price
                            } else {
                                if !self.isCompanySaved(symbol: symbol!) {
                                    if let compData = self.saveCompany(symbol: symbol!, lastPrice: 0.0) {
                                        let full = FullCompanyData()
                                        full.companyData = compData
                                        full.symbol = symbol!
                                        full.currentPrice = price
                                        self.companies.append(full)
                                    }
                                } else {
                                    let compData = self.getCompanyBySymbol(symbol: symbol!)
                                    let full = FullCompanyData()
                                    full.companyData = compData
                                    full.symbol = symbol!
                                    full.currentPrice = price
                                    self.companies.append(full)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func evaluateData(data: Data, symbol: String) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any] {
                let company = self.companies.filter { comp in
                    return comp.symbol == symbol
                }
                let fullData: FullCompanyData
                if company.isEmpty {
                    fullData = FullCompanyData()
                    fullData.symbol = symbol
                    fullData.currentPrice = 0.0
                } else {
                    fullData = company[0]
                }
                
                fullData.name = json["name"] as? String ?? ""
                fullData.sector = json["finnhubIndustry"] as? String ?? ""
                fullData.logoUrl = json["logo"] as? String ?? ""
                fullData.exchange = json["exchange"] as? String ?? ""
            }
        } catch {
            return
        }
    }
    
    private func readJsonFile() -> [String: Any]? {
        if let path = Bundle.main.path(forResource: "companies", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                return jsonResult as? [String: Any]
            } catch {
                return nil
            }
        }
        return nil
    }
    
    private func parseJsonString(jsonString: String) -> [String: Any]? {
        let data = jsonString.data(using: .utf8)!
        do {
            return try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any]
        } catch {
            return nil
        }
    }
    
    private func getSavedData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
          
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CompanyData")
        do {
            let result = try managedContext.fetch(fetchRequest)
            self.companies.removeAll()
            for compData in result {
                let fullData = FullCompanyData()
                fullData.companyData = compData as? CompanyData
                fullData.symbol = fullData.companyData?.symbol ?? ""
                self.companies.append(fullData)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func isCompanySaved(symbol: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext
          
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CompanyData")
        let predicate = NSPredicate(format: "symbol = %@", symbol)
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            return !result.isEmpty
        } catch {
            return false
        }
    }
    
    private func getCompanyBySymbol(symbol: String) -> CompanyData? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
          
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CompanyData")
        let predicate = NSPredicate(format: "symbol = %@", symbol)
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            return !result.isEmpty ? result[0] as? CompanyData : nil
        } catch {
            return nil
        }
    }
    
    private func saveCompany(symbol: String, lastPrice: Double) -> CompanyData? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
          
        let entity = NSEntityDescription.entity(forEntityName: "CompanyData", in: managedContext)!
        let company = NSManagedObject(entity: entity, insertInto: managedContext)
        company.setValue(symbol, forKeyPath: "symbol")
        company.setValue(lastPrice, forKeyPath: "lastPrice")

        do {
            try managedContext.save()
            return company as? CompanyData
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    private func updateCompany(symbol: String, lastPrice: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
          
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CompanyData")
        let predicate = NSPredicate(format: "symbol = %@", symbol)
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if result.isEmpty { return }
            
            result[0].setValue(symbol, forKeyPath: "symbol")
            result[0].setValue(lastPrice, forKeyPath: "lastPrice")
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
