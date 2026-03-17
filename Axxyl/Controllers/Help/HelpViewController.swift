//
//  HelpViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 26/01/23.
//

import UIKit

let section0 = ["Terms and Conditions"]
let section1 = ["Report an accident", "Cancellation fee issue", "Ended ride too early", "Report found item", "Claim lost item fee"]
let section2 = ["Drive not same as pic", "Issue with driver", "Car is not same as registration", "Request a refund", "Billing issue"]


class HelpViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showDetailsForHelpTopic(indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Help", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "HelpTopicDetailsViewController") as! HelpTopicDetailsViewController
        vcToOpen.topic = getTopicForIndexPath(indexPath: indexPath)
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    func getTopicForIndexPath(indexPath: IndexPath) -> String {
        if indexPath.section == 0 {
            return section0[indexPath.row]
        }else if indexPath.section == 1 {
            return section1[indexPath.row]
        }else if indexPath.section == 2 {
            return section2[indexPath.row]
        }
        return ""
    }
}

extension HelpViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return section1.count
        }else if section == 2 {
            return section2.count
        }
        return section0.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultcellidentifier") ?? UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "defaultcellidentifier")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = getTopicForIndexPath(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.showDetailsForHelpTopic(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Common issues"
        }else if section == 2 {
            return "More help topics"
        }
        return nil
    }
}
