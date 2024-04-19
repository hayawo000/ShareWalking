//
//  NormalFirestore.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/20.
//

import Foundation
import MapKit
import Firebase

struct NormalFirestore: Identifiable{
    var id = UUID()
    var name: String
    var keypoint: [GeoPoint]
    var street: [GeoPoint]
}

