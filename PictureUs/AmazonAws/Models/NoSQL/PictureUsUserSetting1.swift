//
//  PictureUsUserSetting1.swift
//  MySampleApp
//
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.4
//

import Foundation
import UIKit
import AWSDynamoDB

class PictureUsUserSetting1: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _circle: String?
    var _doubleTap: String?
    var _down: String?
    var _downLeft: String?
    var _downRight: String?
    var _iMessageContacts: String?
    var _iMessageText: String?
    var _left: String?
    var _right: String?
    var _tap: String?
    var _up: String?
    var _upLeft: String?
    var _upRight: String?
    
    class func dynamoDBTableName() -> String {

        return "pictureusaws-mobilehub-915003100-PictureUsUserSetting1"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any] {
        return [
               "_userId" as NSObject : "userId" as AnyObject,
               "_circle" as NSObject : "Circle" as AnyObject,
               "_doubleTap" as NSObject : "DoubleTap" as AnyObject,
               "_down" as NSObject : "Down" as AnyObject,
               "_downLeft" as NSObject : "DownLeft" as AnyObject,
               "_downRight" as NSObject : "DownRight" as AnyObject,
               "_iMessageContacts" as NSObject : "IMessageContacts" as AnyObject,
               "_iMessageText" as NSObject : "IMessageText" as AnyObject,
               "_left" as NSObject : "Left" as AnyObject,
               "_right" as NSObject : "Right" as AnyObject,
               "_tap" as NSObject : "Tap" as AnyObject,
               "_up" as NSObject : "Up" as AnyObject,
               "_upLeft" as NSObject : "UpLeft" as AnyObject,
               "_upRight" as NSObject : "UpRight" as AnyObject,
        ]
    }
}
