//
//  HomeViewController.swift
//  MKLOCATION TEST
//
//  Created by Sunbu on 2019/6/19.
//  Copyright © 2019 Sunbu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    let taiwanBigTeamLogo = UIImageView()
    let iconBackground = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        taiwanBigTeamLogo.image = UIImage(named: "Icon")
        taiwanBigTeamLogo.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        taiwanBigTeamLogo.center = view.center
        
        iconBackground.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        iconBackground.frame = CGRect(x: 0, y: 0, width: 10000, height: 10000)
        iconBackground.center = view.center
        
        view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        view.addSubview(iconBackground)
        view.addSubview(taiwanBigTeamLogo)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1, animations: {
            self.taiwanBigTeamLogo.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            self.taiwanBigTeamLogo.center = self.view.center
        }) { (finished) in
            UIView.animate(withDuration: 3, animations: {
                self.taiwanBigTeamLogo.frame = CGRect(x: 0, y: 0, width: 10000, height: 10000)
                self.taiwanBigTeamLogo.center = self.view.center
                self.taiwanBigTeamLogo.alpha = 0
                self.iconBackground.alpha = 0
                
            })
        }


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
