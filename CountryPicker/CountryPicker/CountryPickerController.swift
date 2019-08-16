//
//  CountryPickerController.swift
//  CountryCodeInSwift3
//
//  Created by cl-macmini-68 on 09/02/17.
//  Copyright © 2017 Suryakant. All rights reserved.
//

import UIKit

open class CountryPickerController: UIViewController {
    
    // MARK: - Variables
    var countries = [Country]()
    var filterCountries = [Country]()
    var applySearch = false
    
    var callBack: (( _ choosenCountry: Country) -> Void)?
    
    let bundle = Bundle(for: CountryPickerController.self)
    
    //MARK: View and ViewController
    var presentingVC: UIViewController?
    var searchController = UISearchController(searchResultsController: nil)
    let tableView =  UITableView()
    
    /// Properties for countryPicker controller
    public var statusBarStyle: UIStatusBarStyle? = .default
    public var isStatusBarVisible = true
    
    public var labelFont: UIFont = UIFont.systemFont(ofSize: 14.0) {
        didSet { self.tableView.reloadData() }
    }
    
    public var labelColor: UIColor = UIColor.black {
        didSet { self.tableView.reloadData() }
    }
    
    public var detailFont: UIFont = UIFont.systemFont(ofSize: 11.0) {
        didSet { self.tableView.reloadData() }
    }
    
    public var detailColor: UIColor = UIColor.lightGray {
        didSet { self.tableView.reloadData() }
    }
    
    public var separatorLineColor: UIColor = UIColor.lightGray {
        didSet { self.tableView.reloadData() }
    }
    
    public var isHideFlagImage: Bool = false {
        didSet { self.tableView.reloadData() }
    }
    
    public var isHideDiallingCode: Bool = false {
        didSet { self.tableView.reloadData() }
    }
    
    internal var checkMarkImage: UIImage? {
        return UIImage(named: "tickMark", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }
    
    // MARK: - View life cycle
    fileprivate func setUpsSearchController() {
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .default
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search country name here.."
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        
        definesPresentationContext = true
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // Setup view bar buttons
        let uiBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(CountryPickerController.crossButtonClicked(_:)))
        navigationItem.leftBarButtonItem = uiBarButtonItem
        
        // Setup table view and cells
        setUpTableView()
        
        let nib = UINib(nibName: "CountryTableViewCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "CountryTableViewCell")
        tableView.register(CountryCell.self, forCellReuseIdentifier: CountryCell.reuseIdentifier)
        
        // Setup search controller view
        setUpsSearchController()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadCountries()
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    private func setUpTableView() {
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets.zero
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                ])
        } else {
            // Fallback on earlier versions
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        }
    }
    
    @discardableResult
    open class func presentController(on viewController: UIViewController, callBack:@escaping (_ chosenCountry: Country) -> Void) -> CountryPickerController {
        let controller = CountryPickerController()
        controller.presentingVC = viewController
        controller.callBack = callBack
        let navigationController = UINavigationController(rootViewController: controller)
        controller.presentingVC?.present(navigationController, animated: true, completion: nil)
        return controller
    }
    
    // MARK: - Cross Button Action
    @objc func crossButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Others
    func loadCountries() {
        countries = CountryManager.shared.allCountries()
        tableView.reloadData()
    }
}

// MARK: - TableView DataSource
extension CountryPickerController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch applySearch {
        case false:
            return countries.count
        case true:
            return filterCountries.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.reuseIdentifier) as? CountryCell else {
            fatalError("Cell with Identifier CountryTableViewCell cann't dequed")
        }
        
        cell.accessoryType = .none
        cell.checkMarkImageView.isHidden = true
        cell.checkMarkImageView.image = checkMarkImage
        
        var country: Country
        
        if applySearch {
            country = filterCountries[indexPath.row]
        } else {
            country = countries[indexPath.row]
        }
        
        if let alreadySelectedCountry = CountryManager.shared.lastCountrySelected {
            cell.checkMarkImageView.isHidden = country.countryCode == alreadySelectedCountry.countryCode ? false : true
        }
        
        cell.country = country
        setUpCellProperties(cell: cell)
        
        return cell
    }
    
    func setUpCellProperties(cell: CountryCell) {
        cell.nameLabel.font = self.labelFont
        cell.nameLabel.textColor = self.labelColor
        cell.diallingCodeLabel.font = self.detailFont
        cell.diallingCodeLabel.textColor = self.detailColor
        cell.flagImageView.isHidden = self.isHideFlagImage
        cell.diallingCodeLabel.isHidden = self.isHideDiallingCode
        cell.separatorLineView.backgroundColor = self.separatorLineColor
    }
    
    // MARK: - TableView Delegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch applySearch {
        case true:
            let country = filterCountries[indexPath.row]
            self.callBack?(country)
            CountryManager.shared.lastCountrySelected = country
            self.dismiss(animated: false, completion: nil)
        case false:
            let country = countries[indexPath.row]
            self.callBack?(country)
            CountryManager.shared.lastCountrySelected = country
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
}

// MARK: - UISearchBarDelegate
extension CountryPickerController: UISearchBarDelegate {
    // MARK: - SearchBar Delegate
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //code for filter
        if searchBar.text != ""{
            applySearch = true
            filterCountries = []
            let searchString = searchBar.text
            for country in countries {
                if ((country.countryName.uppercased()) as NSString).hasPrefix((searchString?.uppercased())!) {
                    self.filterCountries.append(country)
                }
            }
        } else {
            applySearch = false
        }
        // Reload the tableview.
        tableView.reloadData()
    }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        applySearch = false
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
