//
//  CountryListViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 07/03/23.
//

import UIKit

struct Country: Decodable {
    let name: String
    let dial_code: String
    let code: String
}

protocol CountryCodeSelectionDelegate : NSObject {
    func didSelectCountry(country: Country)
}

class CountryListViewController: UITableViewController {
    
    var countries: [Country] = []
    var sectionIndexTitles: [String] = []
    var sectionIndexMap: [String: Int] = [:]
    weak var delegate : CountryCodeSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Country Codes"
        if let path = Bundle.main.path(forResource: "CountryCodes", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                countries = try decoder.decode([Country].self, from: jsonData)
                
                // Sort the countries array by country name
                countries.sort(by: { $0.name < $1.name })
                
                // Populate the section index titles array and section index map dictionary
                for (index, country) in countries.enumerated() {
                    let sectionTitle = String(country.name.prefix(1)).uppercased()
                    if !sectionIndexTitles.contains(sectionTitle) {
                        sectionIndexTitles.append(sectionTitle)
                        sectionIndexMap[sectionTitle] = index
                    }
                }
                
                tableView.reloadData()
            } catch {
                print("Error parsing countries JSON: \(error)")
            }
        }
        
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.done, target: self, action: #selector(cancelCodeSelection))
        self.navigationItem.leftBarButtonItem = cancelBtn
    }
    
    @objc func cancelCodeSelection() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionIndexTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sectionIndexTitles[section]
        let startIndex = sectionIndexMap[sectionTitle]!
        var endIndex = countries.count - 1
        if section < sectionIndexTitles.count - 1 {
            endIndex = sectionIndexMap[sectionIndexTitles[section + 1]]! - 1
        }
        return endIndex - startIndex + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "CountryCell")
        
        let sectionTitle = sectionIndexTitles[indexPath.section]
        let startIndex = sectionIndexMap[sectionTitle]!
        let country = countries[startIndex + indexPath.row]
        
        cell.textLabel?.text = country.name
        cell.detailTextLabel?.text = country.dial_code
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionIndexTitles[section]
    }
    
    // MARK: - Table view delegate
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectionIndexMap[title]!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionTitle = sectionIndexTitles[indexPath.section]
        let startIndex = sectionIndexMap[sectionTitle]!
        let country = countries[startIndex + indexPath.row]
        print("selected country code -\(country.dial_code)" )
        self.delegate?.didSelectCountry(country: country)
        self.dismiss(animated: true)
    }
}
