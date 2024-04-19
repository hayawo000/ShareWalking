//
//  MakingCoursePoint.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/20.
//

import Foundation
import MapKit

struct MakingCoursePoint : Identifiable {
    let id = UUID()
    var isKeyPoint: Bool
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
