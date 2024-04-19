//
//  LocationManager.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/18.
//

import Foundation
import Firebase
import MapKit

class MakingCourseManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    @Published var region =  MKCoordinateRegion()
    @Published var courseName = ""
    @Published var isMakingcourse = false
    @Published var walkingCourse: [MakingCoursePoint] = []
    
    var walkingStreetList:[GeoPoint] = []
    var keyPointList:[GeoPoint] = []
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.distanceFilter = 20
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locations.last.map {
            let center = CLLocationCoordinate2D(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude)
            
            region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 1000.0,
                longitudinalMeters: 1000.0
            )
        }
        
        if isMakingcourse {
            walkingCourse.append(MakingCoursePoint(isKeyPoint: false,
                                                   latitude: region.center.latitude,
                                                   longitude: region.center.longitude))
            
            walkingStreetList.append(GeoPoint(latitude: region.center.latitude,
                                              longitude: region.center.longitude))
        }
    }
    
    func startMakingCourse() {
        isMakingcourse = true
        walkingCourse.append(MakingCoursePoint(isKeyPoint: true,
                                               latitude: region.center.latitude,
                                               longitude: region.center.longitude))
        keyPointList.append(GeoPoint(latitude: region.center.latitude,
                                       longitude: region.center.longitude))
    }
    
    func stopMakingCourse() {
        isMakingcourse = false
        walkingCourse.append(MakingCoursePoint(isKeyPoint: true,
                                               latitude: region.center.latitude,
                                               longitude: region.center.longitude))
        keyPointList.append(GeoPoint(latitude: region.center.latitude,
                                       longitude: region.center.longitude))
    }
    
    func saveNewCheckpoint() {
        walkingCourse.append(MakingCoursePoint(isKeyPoint: true,
                                               latitude: region.center.latitude,
                                               longitude: region.center.longitude))
        keyPointList.append(GeoPoint(latitude: region.center.latitude,
                                       longitude: region.center.longitude))
    }
    
    func saveCourseOnfirestore() {
        let db = Firestore.firestore()
        db.collection("courses").addDocument(data: ["name": self.courseName, "street":self.walkingStreetList, "keypoint":self.keyPointList]) { error in
            
            if error == nil {
                print("成功しました")
            }
            else {
                print("失敗しました．")
            }
            self.cancelMakingCourse()
        }
    }
    
    func cancelMakingCourse() {
        courseName = ""
        isMakingcourse = false
        walkingCourse = []
        walkingStreetList = []
        keyPointList = []
    }
    
    func startManager() {
        manager.startUpdatingLocation()
    }
    
    func stopManager() {
        manager.stopUpdatingLocation()
    }
    
}
