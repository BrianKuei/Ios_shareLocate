//
//  CreateRoomSelectDestController.swift
//  MKLOCATION TEST
//
//  Created by 張慶宇 on 2019/6/18.
//  Copyright © 2019 Sunbu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON
import Alamofire

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class CreateRoomSelectDestController: UIViewController, UISearchBarDelegate,CLLocationManagerDelegate , MKMapViewDelegate, linkToPreviousMap, HandleMapSearch {
    

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
//    var locationSearchTable: LocationSearchTable?
    var resultSearchController: UISearchController? = nil
    
    // 上一個頁面資料
    var previousInfo = JSON()
    
    
    @IBOutlet weak var setupRoomButton: UIButton!
    @IBAction func setupRoom(_ sender: UIButton) {
        setupRoomButton.isEnabled = false
        setupRoomButton.setTitle("建立中", for: .normal)
        setupRoomButton.backgroundColor = #colorLiteral(red: 0.1716708208, green: 0.5857422774, blue: 0.6859321122, alpha: 1)
        if destination_lat >= -90 && destination_lon >= -360 && source_lat >= -90 && source_lon >= -360{
            let keys = ["name": (previousInfo["roomname"].string)!, "src_lat": source_lat, "src_long": source_lon, "des_lat": destination_lat, "des_long": destination_lon] as [String : Any]
            
            Alamofire.request(commonValues.hostURL+commonValues.addRoomPath, method: .post, parameters: keys, encoding: URLEncoding.default, headers: nil).responseJSON { (res) in
                switch res.result{
                case .success(let resData):
                    // 若成功會回傳房號
                    let resjson = JSON(resData)
                    var json = JSON()
                    json["roomID"].string = resjson["hashid"].string
                    json["name"].string = self.previousInfo["roomname"].string
                    json["username"].string = self.previousInfo["username"].string
                    json["src_lat"].double = self.source_lat
                    json["src_long"].double = self.source_lon
                    json["des_lat"].double = self.destination_lat
                    json["des_long"].double = self.destination_lon
                    self.performSegue(withIdentifier: "setupToRoom", sender: json)
                case .failure(let err):
                    print("Request failed with error: \(err)")
                    self.setupRoomButton.isEnabled = true
                    self.setupRoomButton.setTitle("伺服器建立失敗", for: .normal)
                    self.setupRoomButton.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                }
            }
        }else{
            self.setupRoomButton.isEnabled = true
            self.setupRoomButton.setTitle("尚未選擇地點", for: .normal)
            self.setupRoomButton.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "搜尋關鍵字"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        locationSearchTable.vcDelegate = self
    }
    
    // HandleMapSearch
    var selectedPin:MKPlacemark? = nil
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let _ = placemark.locality,
            let _ = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    var destination_lat: Double = -90.1
    var destination_lon: Double = -360.1
    var source_lat: Double = -90.1
    var source_lon: Double = -360.1
    func drawRoute(des_lat: Double ,des_long: Double){
        destination_lat = des_lat
        destination_lon = des_long
        source_lat = (locationManager.location?.coordinate.latitude)!
        source_lon = (locationManager.location?.coordinate.longitude)!
        let sourceLocation = CLLocationCoordinate2D(latitude: source_lat, longitude:  source_lon)
        let destinationLocation = CLLocationCoordinate2D(latitude:des_lat , longitude: des_long)
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error)")
                }
                return
            }
            
            //取得路線
            let route = directionResonse.routes[0]
            
            //新增路線到地圖上
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            //zoom到兩個點都可見
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupToRoom" {
            let destVC = segue.destination as! UINavigationController
            let SecVC = destVC.viewControllers.first as! ViewController
            if let json = sender as? JSON {
                SecVC.roomInfo = json
            }
        }
    }

}
