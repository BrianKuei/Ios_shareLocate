//
//  LocationSearchTable.swift
//  mapKit searchLocation
//
//  Created by Sunbu on 2019/6/10.
//  Copyright © 2019 Sunbu. All rights reserved.
//

import UIKit
import MapKit

protocol linkToPreviousMap {
    func drawRoute(des_lat: Double ,des_long: Double)
}

class LocationSearchTable : UITableViewController{
    //儲存搜尋後的解果，以便後續造訪
    var matchingItems:[MKMapItem] = []
    //處理前一個地圖用
    var mapView: MKMapView? = nil
    
    var vcDelegate: linkToPreviousMap?
    
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}

//Set up the API call
extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //The guard statement unwraps the optional values for mapView and the search bar text.
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        //search.Request 是由 search string以及 map region提供的 location context構成，search string是由search bar 而 map region是由 mapView
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        //對請求對象執行實際搜索。
        let search = MKLocalSearch(request: request)
    
        
        //會是一個mapItems的陣列
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            //儲存mapItems
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

//Set up the Table View Data Source
extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
}


extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        vcDelegate?.drawRoute(des_lat: selectedItem.coordinate.latitude, des_long: selectedItem.coordinate.longitude)
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}


