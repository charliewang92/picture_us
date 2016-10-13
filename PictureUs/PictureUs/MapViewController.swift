//
//  MapViewController.swift
//  PictureUs
//
//  Created by Charlie Wang on 10/3/16.
//  Copyright © 2016 Charlie Wang. All rights reserved.
//

import UIKit
import CoreLocation


class MapViewController: UIViewController, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private var previousPoint:CLLocation?
    private var totalMovementDistance:CLLocationDistance = 0
    @IBOutlet var latLabel: UILabel!
    
    @IBOutlet var longLabel: UILabel!
    @IBOutlet var distanceTraveledLabel: UILabel!
    
    @IBOutlet var longValueLabel: UILabel!
    @IBOutlet var latValueLabel: UILabel!
    @IBOutlet var distValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager:CLLocationManager, didChangeAuthorizationStatus status:CLAuthorizationStatus) {
        print("auth")
        switch status {
        case .authorized, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            locationManager.stopUpdatingLocation()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
