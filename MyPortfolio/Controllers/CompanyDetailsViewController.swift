//
//  CompanyDetailsViewController.swift
//  MyPortfolio
//
//  Created by Tamási Móni on 2021. 03. 03..
//

import Foundation
import UIKit

class CompanyDetailsViewController: UIViewController {
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var sectorName: UILabel!
    @IBOutlet weak var symbolText: UILabel!
    @IBOutlet weak var priceText: UILabel!
    @IBOutlet weak var indicatorImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var exchangeText: UILabel!
    
    var companySymbol: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommunicationManager.shared.downloadCompanyDetails(symbol: self.companySymbol ?? "") {success, error in
            DispatchQueue.main.async {
                self.handleResponse(success: success, error: error)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .darkContent
    }
    
    private func handleResponse(success: Bool, error: String?) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        
        if !success {
            let message: String
            if error != nil {
                message = error!
            } else {
                message = "Unknown error occured"
            }
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            }
            alert.addAction(action)
            self.navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        
        let company = DataManager.shared.companies.filter { comp in
            return comp.symbol == self.companySymbol
        }
        if company.isEmpty {
            let alert = UIAlertController(title: "Error", message: "No data available", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            }
            alert.addAction(action)
            self.navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        
        if !company[0].logoUrl.isEmpty {
            if let uri = URL(string: company[0].logoUrl) {
                self.companyLogo.downloaded(from: uri, contentMode: UIView.ContentMode.scaleAspectFit)
            }
        } else {
            self.companyLogo.isHidden = false
        }
        
        self.companyName.text = company[0].name
        self.symbolText.text = self.companySymbol
        self.indicatorImage.isHidden = false
        switch(company[0].getPriceChangeIndicator()) {
        case .noData:
            self.priceText.text = "__.__"
            self.priceText.textColor = Constants.grayColor
            self.indicatorImage.isHidden = true
        case .noFreshData:
            self.priceText.text = String(format: "%.2f", company[0].companyData!.lastPrice)
            self.priceText.textColor = Constants.grayColor
            self.indicatorImage.isHidden = true
        case .noReferenceData:
            self.priceText.text = String(format: "%.2f", company[0].currentPrice)
            self.priceText.textColor = Constants.grayColor
            self.indicatorImage.isHidden = true
        case .still:
            self.priceText.text = String(format: "%.2f", company[0].currentPrice)
            self.priceText.textColor = Constants.grayColor
            self.indicatorImage.image = UIImage(named: "still")
        case .down:
            self.priceText.text = String(format: "%.2f", company[0].currentPrice)
            self.priceText.textColor = Constants.redColor
            self.indicatorImage.image = UIImage(named: "down")
        case .up:
            self.priceText.text = String(format: "%.2f", company[0].currentPrice)
            self.priceText.textColor = Constants.greenColor
            self.indicatorImage.image = UIImage(named: "up")
        }
        self.sectorName.text = company[0].sector
        self.indicatorImage.isHidden = false
        self.exchangeText.text = company[0].exchange
    }
}
