//
//  NormalManager.swift
//  HealthWalking
//
//  Created by 小田敏人 on 2022/09/18.
//#imageLiteral(resourceName: "simulator_screenshot_E135F323-5DA6-4A2D-A711-A0CBB8A4688C.png")

import Foundation
import MapKit
import CoreMotion
import Firebase
import UserNotifications

class NormalManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    let pedometer = CMPedometer()
    
    @Published var courseName = ""
    @Published var region =  MKCoordinateRegion()
    @Published var walkingCourse: [NormalPoint] = []
    @Published var averageRegion = MKCoordinateRegion()
    @Published var canStart = false
    @Published var isWalking = false
    @Published var isEndWalking = false
    @Published var locationCenter = CLLocation()
    @Published var startPoint = CLLocation()
    @Published var nextPoint = CLLocation()
    @Published var pointCount = 0
    
    @Published var startTime = Date()
    @Published var endTime = Date()
    @Published var resultTime = ""
    
    @Published var count = 0
    @Published var meter : Double?
    
    var testFirestore = NormalFirestore(name: "", keypoint: [], street: [])
    var checkCount = 0
    
    private var dateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter
    }()
    
    override init() {
        super.init()
        self.requestPermission()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 20
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locations.last.map {
            let center = CLLocationCoordinate2D(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude)
            
            locationCenter = CLLocation(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude
            )
            
            region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 1000.0,
                longitudinalMeters: 1000.0
            )
        }
        
        
        if startPoint.distance(from: locationCenter) < 50 && !isWalking {
            canStart = true
        }
        else {
            canStart = false
        }
        
        if isWalking {
            if nextPoint.distance(from: locationCenter) < 50 {
                settingNextPoint()
            }
        }
    }
    
    func loadPointFromFirestore(documentID: String) {
        let db = Firestore.firestore()
        db.collection("courses").document(documentID).getDocument { (snap, error) in
            if let error = error {
                fatalError("\(error)")
            }
            guard let data = snap?.data() else { return }
            DispatchQueue.main.async {
                self.testFirestore = NormalFirestore(name: data["name"] as? String ?? "",
                                                keypoint: data["keypoint"] as? [GeoPoint] ?? [],
                                                street: data["street"] as? [GeoPoint] ?? [])
                self.loadCourse()
            }
        }
    }
    
    func loadCourse() {
        var latCount: Double = 0.0
        var lonCount: Double = 0.0
        var testWalkingCourse : [NormalPoint] = []
        courseName = testFirestore.name
        for i in 0 ..< testFirestore.keypoint.count {
            latCount += testFirestore.keypoint[i].latitude
            lonCount += testFirestore.keypoint[i].longitude
            if i == 0 {
                testWalkingCourse.append(NormalPoint(pointName: "スタート", isKeyPoint: true,isChecked: false,
                                                 latitude: testFirestore.keypoint[i].latitude, longitude: testFirestore.keypoint[i].longitude))
            }
            else if i == testFirestore.keypoint.count - 1 {
                testWalkingCourse.append(NormalPoint(pointName: "ゴール", isKeyPoint: true, isChecked: false,
                                                 latitude: testFirestore.keypoint[i].latitude, longitude: testFirestore.keypoint[i].longitude))
            }
            else {
                testWalkingCourse.append(NormalPoint(pointName: "チェックポイント\(i)", isKeyPoint: true, isChecked: false,
                                                 latitude: testFirestore.keypoint[i].latitude, longitude: testFirestore.keypoint[i].longitude))
            }
        }
        
        latCount = latCount / Double(testFirestore.keypoint.count)
        lonCount = lonCount / Double(testFirestore.keypoint.count)
        averageRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latCount, longitude: lonCount),
            latitudinalMeters: 1000.0,
            longitudinalMeters: 1000.0
        )
        
        for j in 0 ..< testFirestore.street.count {
            testWalkingCourse.append(NormalPoint(pointName: "", isKeyPoint: false, isChecked: false,
                                             latitude: testFirestore.street[j].latitude, longitude: testFirestore.street[j].longitude))
        }
        walkingCourse = testWalkingCourse
        startPoint = CLLocation(latitude: walkingCourse[0].latitude, longitude: walkingCourse[0].longitude)
    }
    
    func resetCourse() {
        walkingCourse = []
        averageRegion = region
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
                // print("Permission granted: \(granted)")
            }
    }
    
    func startWalking() {
        startTime = Date()
        stepCountStart()
        walkingCourse[pointCount].isChecked = true
        isWalking = true
        pointCount += 1
        nextPoint = CLLocation(latitude: walkingCourse[pointCount].latitude, longitude: walkingCourse[pointCount].longitude)
    }
    
    func settingNextPoint() {
        walkingCourse[pointCount].isChecked = true
        pointCount += 1
        if pointCount == testFirestore.keypoint.count {
            makeNotification(commit: "ゴールに到着しました", isGoal: true)
            endWalking()
        }
        else {
            makeNotification(commit: "チェックポイント\(pointCount - 1)に到着しました", isGoal: false)
            nextPoint = CLLocation(latitude: walkingCourse[pointCount].latitude, longitude: walkingCourse[pointCount].longitude)
        }
    }
    
    func endWalking() {
        endTime = Date()
        stepCountstop()
        calcResultTime()
        isWalking = false
        isEndWalking = true
        
        pointCount = 0
        walkingCourse = []
        startPoint = CLLocation()
        nextPoint = CLLocation()
    }
    
    func calcResultTime() {
        let cal = Calendar(identifier: .gregorian)
        let dif = cal.dateComponents([.second], from: startTime, to: endTime)
        resultTime = dateFormatter.string(from: dif)!
        
    }
    
    func makeNotification(commit: String, isGoal: Bool){
        //②通知タイミングを指定
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        //③通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = isGoal ? "ゴール到着" : "チェックポイント到着"
        content.body = commit
        content.sound = UNNotificationSound.default
        //④通知タイミングと通知内容をまとめてリクエストを作成。
        let request = UNNotificationRequest(identifier: "notification001", content: content, trigger: trigger)
        //⑤④のリクエストの通りに通知を実行させる
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        //print("作業完了")
    }
    
    func saveResultOnfirestore() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        let db = Firestore.firestore()
        db.collection("records").addDocument(data: ["course": self.courseName,
                                                    "date": formatter.string(from: Date()),
                                                    "user": username,
                                                    "time": self.resultTime,
                                                    "steps": self.count,
                                                    "distance":self.meter ?? 0.0]) { error in
            if error == nil {
                print("成功しました")
            }
            
            else {
                print("失敗しました")
            }
            
            DispatchQueue.main.async {
                self.reset()
            }
        }
    }
    
    func reset() {
        isEndWalking = false
        pointCount = 0
        count = 0
        meter = nil
        walkingCourse = []
        startPoint = CLLocation()
        nextPoint = CLLocation()
    }
    
    func startManager() {
        manager.startUpdatingLocation()
    }
    
    func stopManager() {
        manager.stopUpdatingLocation()
    }
    
}

extension NormalManager {
    
    func stepCountStart() {
        pedometer.startUpdates(from: Date()) { (data, error) in
            guard error == nil else {
                print("error \(String(describing: error))")
                return
            }
            
            DispatchQueue.main.async {
                self.count = data?.numberOfSteps as! Int
                self.meter = data?.distance as? Double
                if self.meter != nil {
                    self.meter = self.meter! * 10
                    self.meter = round(self.meter!) / 10.0
                }
            }
        }
        print("歩数計測開始")
    }
    
    func stepCountstop() {
        pedometer.stopUpdates()
        print("歩数計測終了")
    }
}

