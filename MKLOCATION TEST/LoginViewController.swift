//
//  LoginViewController.swift
//  MKLOCATION TEST
//
//  Created by 張慶宇 on 2019/6/18.
//  Copyright © 2019 Sunbu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {

    @IBOutlet weak var userid: UITextField!
    @IBOutlet weak var roomnumber: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginButton_Action(_ sender: Any) {
        loginButton.isEnabled = false
        loginButton.setTitle("登入中", for: .normal)
        loginButton.backgroundColor = #colorLiteral(red: 0.1716708208, green: 0.5857422774, blue: 0.6859321122, alpha: 1)
        if roomnumber.text != "" && userid.text != ""{
            let keys = ["roomID": (roomnumber.text!)] as [String: Any]
            Alamofire.request(commonValues.hostURL + commonValues.getRoomInfoPath, method: .post, parameters: keys, encoding: URLEncoding.default, headers: nil).responseJSON { (res) in
                switch res.result{
                case .success(let resData):
                    // 結構: {name: 房名, src_lat: 出發地緯度, src_long: 出發地經度, des_lat: 目的地緯度, des_long: 目的地經度}
                    var json = JSON(resData)
                    json["roomID"].string = self.roomnumber.text
                    json["username"].string = self.userid.text
                    self.performSegue(withIdentifier: "loginToRoom", sender: json)
                case .failure(let err):
                    print("Request failed with error: \(err)")
                }
                self.loginButton.isEnabled = true
                self.loginButton.setTitle("登入", for: .normal)
                self.loginButton.backgroundColor = #colorLiteral(red: 0.2524167597, green: 0.8552529216, blue: 0.9999298453, alpha: 1)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToRoom" {
            let destVC = segue.destination as! UINavigationController
            let SecVC = destVC.viewControllers.first as! ViewController
            if let json = sender as? JSON {
                SecVC.roomInfo = json
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
