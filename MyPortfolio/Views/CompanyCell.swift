//
//  CompanyCell.swift
//  MyPortfolio
//
//  Created by Tamási Móni on 2021. 03. 03..
//

import Foundation
import UIKit

class CompanyCell: UICollectionViewCell {
    
    @IBOutlet weak var symbolName: UILabel!
    @IBOutlet weak var currentValue: UILabel!
    @IBOutlet weak var changeIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setData(company: FullCompanyData) {
        
        self.layer.borderWidth = 1.5
        self.layer.borderColor = Constants.grayColor.cgColor
        self.layer.cornerRadius = 5.0
        
        self.symbolName.text = company.symbol
        self.changeIcon.isHidden = false

        switch(company.getPriceChangeIndicator()) {
        case .noData:
            self.currentValue.text = "__.__"
            self.currentValue.textColor = .white
            self.changeIcon.isHidden = true
        case .noFreshData:
            self.currentValue.text = String(format: "%.2f", company.companyData!.lastPrice)
            self.currentValue.textColor = .white
            self.changeIcon.isHidden = true
        case .noReferenceData:
            self.currentValue.text = String(format: "%.2f", company.currentPrice)
            self.currentValue.textColor = .white
            self.changeIcon.isHidden = true
        case .still:
            self.currentValue.text = String(format: "%.2f", company.currentPrice)
            self.currentValue.textColor = .white
            self.changeIcon.image = UIImage(named: "still")
        case .down:
            self.currentValue.text = String(format: "%.2f", company.currentPrice)
            self.currentValue.textColor = Constants.redColor
            self.changeIcon.image = UIImage(named: "down")
        case .up:
            self.currentValue.text = String(format: "%.2f", company.currentPrice)
            self.currentValue.textColor = Constants.greenColor
            self.changeIcon.image = UIImage(named: "up")
        }
    }
}
