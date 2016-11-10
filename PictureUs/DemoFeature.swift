//
//  DemoFeature.swift
//  Swiper
//
//  Created by Charlie Wang on 11/9/16.
//  Copyright © 2016 Charlie Wang. All rights reserved.
//

import Foundation

class DemoFeature: NSObject {
    
    var displayName: String
    var detailText: String
    var icon: String
    var storyboard: String
    
    init(name: String, detail: String, icon: String, storyboard: String) {
        self.displayName = name
        self.detailText = detail
        self.icon = icon
        self.storyboard = storyboard
        super.init()
    }
}
