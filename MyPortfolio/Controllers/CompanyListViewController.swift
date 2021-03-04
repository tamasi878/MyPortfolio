//
//  CompanyListViewController.swift
//  MyPortfolio
//
//  Created by Tamási Móni on 2021. 03. 01..
//

import Foundation
import UIKit

class CompanyListViewController: UIViewController {
    private let companyCellIdentifier = "CompanyCell"

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var companies: [FullCompanyData] = [FullCompanyData]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "MY PORTFOLIO"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(UINib(nibName: "CompanyCell", bundle: nil), forCellWithReuseIdentifier: companyCellIdentifier)
        self.companies = DataManager.shared.companies
        
        let backItem = UIBarButtonItem()
        backItem.title = "BACK"
        self.navigationItem.backBarButtonItem = backItem
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .darkContent
    }
    
    func displayNoConnection(display: Bool) {
        if display {
            self.errorLabel.text = "No socket connection"
        }
        self.errorView.isHidden = !display
    }
    
    func displayConnectionError(error: String) {
        self.errorLabel.text = error
        self.errorView.isHidden = false
    }
    
    func refreshList() {
        self.indicator.stopAnimating()
        self.indicator.isHidden = true
        
        self.companies = DataManager.shared.companies
        self.collectionView.reloadData()
    }
}

extension CompanyListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.companies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: companyCellIdentifier, for: indexPath) as! CompanyCell

        cell.setData(company: self.companies[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let company = self.companies[indexPath.row]
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let detailsViewController = CompanyDetailsViewController(nibName: "CompanyDetailsViewController", bundle: nil)
        detailsViewController.title = company.symbol
        detailsViewController.companySymbol = company.symbol
                
        self.navigationController?.pushViewController(detailsViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150.0, height: 150.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}


