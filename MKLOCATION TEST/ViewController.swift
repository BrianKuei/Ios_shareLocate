//
//  ViewController.swift
//  MKLOCATION TEST
//
//  Created by Sunbu on 2019/6/11.
//  Copyright © 2019 Sunbu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import NotificationBannerSwift
import SwiftyJSON
import SocketIO


class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate{
    @IBAction func copyRoomNum(_ sender: UIButton) {
        let copyRoomNum = roomInfo?["roomID"].string
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = copyRoomNum
//        print("room num is \(copyRoomNum)")
//        print(pasteBoard.string)
    }
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var RoomNavigation: UINavigationItem!
    @IBOutlet weak var roomID: UITextView!
    var roomInfo: JSON?
    var locationManager = CLLocationManager()
    let socketManager = SocketManager(socketURL: URL(string: commonValues.hostURL)!, config: [.log(false), .compress])
    var socket: SocketIOClient!
    var members = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomID.text = roomInfo?["roomID"].string
        RoomNavigation.title = roomInfo?["name"].string
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        
        socket = socketManager.defaultSocket
        SocketIO_addHandler()
        socket.connect()
        socket.on("connect"){data, _ in
            let emitInfo = ["room": (self.roomInfo?["roomID"].string)!, "MAC": commonValues.adId, "name": (self.roomInfo?["username"].string)! ,"axis": ["lat": self.locationManager.location?.coordinate.latitude ?? 22.6676484, "long": self.locationManager.location?.coordinate.longitude ?? 120.997315]] as [String: Any]
            self.SocketIO_EnterAndGetRoomDetail(emitData: emitInfo)
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.SocketIO_updateMyCoordinate(emitData: ["room": (self.roomInfo?["roomID"].string)!, "MAC": commonValues.adId, "axis": ["lat": self.locationManager.location?.coordinate.latitude ?? 22.6676484, "long": self.locationManager.location?.coordinate.longitude ?? 120.997315]] as [String:Any])
            self.drawUsers()
        }
//        print("起始點：\((roomInfo?["src_lat"].double)!),\((roomInfo?["src_long"].double)!)")
//        print("終點：\((roomInfo?["des_lat"].double)!),\((roomInfo?["des_long"].double)!)")
        drawRoute(src_lat: (roomInfo?["src_lat"].double)!,src_long :(roomInfo?["src_long"].double)!,des_lat :(roomInfo?["des_lat"].double)!,des_long :(roomInfo?["des_long"].double)!)
    }
    
    @IBAction func sendNotify(_ sender: UIButton) {
        SocketIO_SendNotify(emitData: ["room": (roomInfo?["roomID"].string)!, "statusCode": 0, "sender": (roomInfo?["username"].string)! ] as [String:Any])
    }
    func drawRoute(src_lat: Double, src_long: Double, des_lat: Double ,des_long: Double){
        let sourceLocation = CLLocationCoordinate2D(latitude: src_lat, longitude: src_long)
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
    
    func SocketIO_addHandler(){
        socket.on("renew coordinate"){data, _ in
            // {name: "BrainKuei", lat:22.1 ,long:120.1}
            if data.count > 0 {
                let getjson = JSON(data[0])
    //            let latitude = getjson["lat"].double
    //            let longitude = getjson["long"].double
    //            let name = getjson["name"].string
                self.SocketIO_renewOneAxis(data: getjson)
            }
        }
        
        socket.on("receive notification"){data, _ in
            // {"statusCode": 代碼, sender": 是哪個使用者送der}
            let getjson = JSON(data[0])
//            let statusCode = getjson["statusCode"].int
//            let name = getjson["sender"].string
            let banner = NotificationBanner(title: "警告", subtitle: "\(getjson["sender"].string!)發出通知",style: .danger)
            banner.show()
        }
    }
    
    func SocketIO_EnterAndGetRoomDetail(emitData: [String:Any]){
        socket.emitWithAck("entering room", emitData).timingOut(after: 0) { (data) in
            // 這邊他會即時回傳房間所有使用者位置資訊
            // data 結構為 {"MAC1": {name: 使用者名稱, lat: 緯度 ,long: 經度 }, "MAC2": {name: 第二使用者名稱, lat: 緯度 ,long: 經度 }, ...}
            self.members = JSON(data[0])
            /*for (key,subJson):(String, JSON) in JSON(data) {
                // 該for-loop 遞迴 MAC1 再來 MAC2~~~
                let MAC = key
                let name = subJson["name"].string
                let lat = subJson["lat"].double
                let long = subJson["long"].double
            }*/
        }
    }
    
    func SocketIO_updateMyCoordinate(emitData: [String:Any]){
        socket.emit("update coordinate", emitData)
    }
    
    func SocketIO_SendNotify(emitData: [String:Any]){
        socket.emit("room notification", emitData)
    }
    
    func SocketIO_renewOneAxis(data: JSON){
        var count = -1
        var hasIn = false
        for(key, _):(String, JSON) in members{
            count += 1
            let strKey = String(key)
            if members[strKey]["MAC"] == data["MAC"]{
                members[strKey]["lat"] = data["lat"]
                members[strKey]["long"] = data["long"]
                members[strKey]["name"] = data["name"]
                hasIn = true
            }
        }
        if !hasIn{
            let newStrKey = String(count)
            members[newStrKey]["MAC"] = data["MAC"]
            members[newStrKey]["lat"] = data["lat"]
            members[newStrKey]["long"] = data["long"]
            members[newStrKey]["name"] = data["name"]
        }
    }
    
    func drawUsers(){
        mapView.removeAnnotations(mapView.annotations)
        if members.count > 0{
            for (_ ,subJson):(String, JSON) in members {
                if subJson["MAC"].string == commonValues.adId{
                    continue
                }
                let annotation = MKPointAnnotation()
                let location = CLLocationCoordinate2D(latitude: subJson["lat"].double!, longitude: subJson["long"].double!)
                let placemark = MKPlacemark(coordinate: location)
                annotation.coordinate = placemark.coordinate
                annotation.title = subJson["name"].string!
                mapView.addAnnotation(annotation)
            }
        }
    }
}
