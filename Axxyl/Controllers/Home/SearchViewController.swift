//
//  SearchViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 07/10/22.
//

import UIKit
import MapKit

protocol RouteLocationDelegate {
    func pushSelectVehicleWithRouteArray(routeLocations: [MapLocation])
}

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchTableHeight: NSLayoutConstraint!
    
    var searchMachingItmes: [MapLocation] = []
    var stopLocationItems: [MapLocation] = [] //[MapLocation(id: 0, name: "Your Location"), MapLocation(id: 1)]
    var historyItems: [MapLocation] = []//[MapLocation(name: "test", address: "Adding address"), MapLocation(name: "another test", address: "Adding address")]
    var isSearchEnabled: Bool = false
    var editingEnabledFieldTag: Int?
    var mapView: MKMapView?
    var locObj: MapLocation?
    var delegate: RouteLocationDelegate?
    private var currentSearch: MKLocalSearch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSearchTableUI()
    }
    
    func updateSearchTableUI() {
        if let encodedDataArray = UserDefaults.standard.value(forKey: "SEARCH_HISTORY") {
            do {
                let storedItems = try JSONDecoder().decode([MapLocation].self, from: encodedDataArray as! Data)
                historyItems = storedItems
            } catch let err {
                print(err)
            }
        }
        if historyItems.count == 0 && !isSearchEnabled {
            historyTableView.isHidden = true
        } else {
            historyTableView.isHidden = false
        }
        
        if stopLocationItems.count < 4 {
            searchTableHeight.constant = CGFloat((stopLocationItems.count + 1) * 50)
        } else {
            searchTableHeight.constant = CGFloat(stopLocationItems.count * 50)
        }
        searchMachingItmes.removeAll()
        historyTableView.keyboardDismissMode = .onDragWithAccessory
        searchTableView.reloadData()
        historyTableView.reloadData()
    }
    
    @IBAction func dismissSearchController(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func searchRidesBtnPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.pushSelectVehicleWithRouteArray(routeLocations: self.stopLocationItems)
        }
    }
}

extension SearchViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == historyTableView {
            if isSearchEnabled && searchMachingItmes.count > 0 {
                return "SEARCH RESULTS"
            }
            return "RECENT SEARCH"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
            if stopLocationItems.count < 4 {
                return stopLocationItems.count + 1
            }
            return stopLocationItems.count
        } else if isSearchEnabled && searchMachingItmes.count > 0 {
            return searchMachingItmes.count
        }
        return historyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == searchTableView {
            if indexPath.row == stopLocationItems.count && stopLocationItems.count < 4 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Add_Stop_Cell", for: indexPath) as? AddStopTableViewCell {
                    return cell
                }
                
                return AddStopTableViewCell()
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Search_Cell", for: indexPath) as? SearchTableViewCell {
                    let locationData = stopLocationItems[indexPath.row]
                    cell.tripImageView.image = UIImage(named: "Stop.png")
                    cell.tripImageView.tintColor = UIColor(red: 33.0/255.0, green:  33.0/255.0, blue:  33.0/255.0, alpha: 1.0)
                    cell.upperPathConnectorView.isHidden = false
                    cell.lowerPathConnectorView.isHidden = false
                    cell.removeCellBtn.isHidden = false
                    cell.locationTxtFld.autocorrectionType = .no
                    cell.locationTxtFld.tag = indexPath.row
                    cell.removeCellBtn.tag = indexPath.row
                    cell.delegate = self
                    if indexPath.row == 0 {
                        cell.upperPathConnectorView.isHidden = true
                        cell.removeCellBtn.isHidden = true
                        cell.tripImageView.image = UIImage(named: "Play.png")
                        cell.tripImageView.tintColor = UIColor(red: 130.0/255.0, green:  130.0/255.0, blue:  130.0/255.0, alpha: 1.0)
                    }
                    
                    if indexPath.row == 1 {
                        cell.removeCellBtn.isHidden = true
                    }
                    
                    if indexPath.row == stopLocationItems.count - 1 {
                        cell.lowerPathConnectorView.isHidden = true
                    }
                    
                    let locName = locationData.name ?? ""
                    if let locationAddress = locationData.address {
                        cell.locationTxtFld.text = "\(locName): \(locationAddress)"
                    } else {
                        cell.locationTxtFld.text = locName
                    }
                    return cell
                }
                
                return SearchTableViewCell()
            }
        }
        if (tableView == historyTableView) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "History_Cell", for: indexPath) as? HistoryTableViewCell {
                cell.placeTypeImgView.image = UIImage(named: "History_Clock.png")
                if isSearchEnabled && searchMachingItmes.count > 0 {
                    let searchResult = searchMachingItmes[indexPath.row].name
                    cell.placeTitleLbl.text = searchResult
                    cell.placeTypeImgView.image = UIImage(named: "Location_Tag.png")
                    cell.placeAddressLbl.text = searchMachingItmes[indexPath.row].address
                } else {
                    cell.placeTitleLbl.text = historyItems[indexPath.row].name
                    cell.placeAddressLbl.text = historyItems[indexPath.row].address
                }
                return cell
            }
            
            return HistoryTableViewCell()
        }
        return UITableViewCell()
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //printde
        if tableView == searchTableView && indexPath.row == stopLocationItems.count {
            stopLocationItems.append(MapLocation(id: indexPath.row))
            updateSearchTableUI()
        } else if (tableView == historyTableView) {
            if isSearchEnabled {
                if searchMachingItmes.count > 0 {
                    locObj = searchMachingItmes[indexPath.row]
                } else {
                    locObj = historyItems[indexPath.row]
                }
                locObj?.id = editingEnabledFieldTag!
                stopLocationItems[editingEnabledFieldTag!] = locObj!
                if historyItems.count >= 25 {
                    historyItems.remove(at: 0)
                    UserDefaults.standard.storeInToHistory(mapLocation: locObj!)
                    //historyItems.append(locObj!)
                } else if !historyItems.contains(where: { obj in
                    obj.name == locObj?.name
                }) {
                    historyItems.append(locObj!)
                    UserDefaults.standard.storeInToHistory(mapLocation: locObj!)
                }
                isSearchEnabled = false
                updateSearchTableUI()
            }
        }
    }
    
    func didTapRemoveButtonInCell(_ cell: SearchTableViewCell) {
        if stopLocationItems.count > 2 {
            stopLocationItems.remove(at: cell.removeCellBtn.tag)
            updateSearchTableUI()
        }
    }
}

extension SearchViewController: SearchCellDelegate {
    
    func textFieldStartEditingInCell(_ cell: SearchTableViewCell) {
        isSearchEnabled = true
        editingEnabledFieldTag = cell.locationTxtFld.tag
        locObj = stopLocationItems[cell.locationTxtFld.tag]
        searchMachingItmes.removeAll()
        historyTableView.reloadData()
    }
    
    func textFieldDataChangedInCell(_ cell: SearchTableViewCell) {
        guard let searchedText = cell.locationTxtFld.text else { return }
        if !searchedText.isEmpty && historyTableView.isHidden {
            historyTableView.isHidden = false
        }
        locObj?.name = searchedText
        stopLocationItems[cell.locationTxtFld.tag] = locObj!
        //stopLocationItems.first(where: {$0.id == cell.locationTxtFld.tag})?.name = searchedText
        let request = MKLocalSearch.Request()
        // request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.atm, .amusementPark, .airport, .aquarium, .bakery, .bank, .beach, .brewery, .cafe, .campground, .carRental, .evCharger, .fireStation, .fitnessCenter, .foodMarket, .gasStation, .hospital, .hotel, .laundry, .library, .marina, .movieTheater, .nationalPark, .nightlife, .park, .pharmacy, .parking, .police, .postOffice, .publicTransport, .restaurant, .restroom, .school, .stadium, .store, .theater, .university, .winery, .zoo])
            request.naturalLanguageQuery = cell.locationTxtFld.text
//            request.region = mapView!.region
//            let search = MKLocalSearch(request: request)
        
        request.region = MKCoordinateRegion(
            center: mapView!.centerCoordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )

        // 🔥 Cancel previous search (very important)
        currentSearch?.cancel()

        currentSearch = MKLocalSearch(request: request)

        currentSearch?.start { [weak self] response, error in
            guard let self = self, let response = response else { return }

//        search.start(completionHandler: { response, _ in
//            guard let response = response else {
//                return
//            }
            
            self.searchMachingItmes.removeAll()
            for mapItem in response.mapItems {
                self.searchMachingItmes.append(LocationManager.managerObj.parseLocationObj(mapItem: mapItem))
            }
            
            DispatchQueue.main.async {
                self.historyTableView.reloadData()
            }
        }
    }
    
    func textfieldEndEditingInCell(_ cell: SearchTableViewCell) {
        //isSearchEnabled = false
    }
    
}
