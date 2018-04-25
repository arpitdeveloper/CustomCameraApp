//
//  ViewController.swift
//  CustomCamera
//
//  Created by Ankit Nigam on 25/11/17.
//  Copyright © 2017 SumitJagdev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func goToCameraButtonTapped(_ sender: UIButton){
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController
        destVC?.imageNumber = sender.tag + 1
        self.navigationController?.pushViewController(destVC!, animated: true)
    }

}

