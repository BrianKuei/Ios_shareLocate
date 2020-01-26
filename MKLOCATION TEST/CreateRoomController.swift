//
//  CreateRoomController.swift
//  MKLOCATION TEST
//
//  Created by 張慶宇 on 2019/6/18.
//  Copyright © 2019 Sunbu. All rights reserved.
//

import UIKit
import SwiftyJSON

class CreateRoomController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var roomname: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func goToSetDest(_ sender: UIButton) {
        if username.text != "" && roomname.text != "" {
            performSegue(withIdentifier: "setupToDest", sender: JSON(["username": String(username.text!), "roomname": String(roomname.text!)] as [String:Any]))
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupToDest" {
            let destVC = segue.destination as! CreateRoomSelectDestController
            if let json = sender as? JSON {
                destVC.previousInfo = json
            }
        }
    }

}
