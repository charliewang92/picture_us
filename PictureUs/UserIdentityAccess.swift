//
//  UserIdentityAccess.swift
//  Swiper
//
//  Created by Charlie Wang on 10/28/16.
//  Copyright © 2016 Charlie Wang. All rights reserved.
//

import Foundation
import AWSMobileHubHelper

class UserIdentityAccess {
    func getUserIdentity() -> String {
        return AWSIdentityManager.defaultIdentityManager().identityId!
    }
}
