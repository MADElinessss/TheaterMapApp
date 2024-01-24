//
//  ViewController.swift
//  TheaterMapApp
//
//  Created by Madeline on 2024/01/16.
//

import CoreLocation
import MapKit
import UIKit

/*
 MARK: How to Use CoreLocation
 1. import CoreLocation
 2. CLLocationManager: 위치에 대한 대부분을 담당하는 매니저
 대부분의 프레임워크들은 매니저와 같은 중심부가 구현되어있음
 3. 위치 프로토콜 선언 - 머식이 Delegate
 4. 위치 프로토콜 - Delegate 연결
 5. didUpdateLocations: 사용자의 위치를 성공적으로 가져온 경우 실행됨!
 locations - 배열로 들어옴(무슨 해양,, 그런거까지 정보가 많음)
 6. didFailWithError: 실패했을 때에는 디폴트 위치 or 에러 메세지를 띄워야 함
 7. info.plist - 위치 권한 privacy 등록
 Privacy - Location When In Use Usage Description -> 앱 사용하는 동안 허용하겠다
 보통 얘를 디폴트로 사용함

 8. 권한 설정 - 사용자에게 권한 요청하기 위해 iOS 위치 서비스 활성화여부 체크
 9. 사용자 위치 권한 상캐 확인 후에 권한 요청하기
 */

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let manager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // CLLocationManager의 delegate를 현재 ViewController로 설정
        manager.delegate = self

        // 위치 서비스 사용 권한 확인 및 요청
        checkDeviceLocationAuthorization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        
    }
}

// MARK: Authorization 관련
extension ViewController {
    func checkDeviceLocationAuthorization() {
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                
                let authorization: CLAuthorizationStatus
                
                if #available(iOS 14.0, *) {
                    authorization = self.manager.authorizationStatus
                } else {
                    authorization = CLLocationManager.authorizationStatus()
                }
                
                DispatchQueue.main.async {
                    self.checkCurrentAuthorization(authorization)
                }
            } else {
                print("위치 허용 꺼져있음")
            }
        }
    }
    
    func checkCurrentAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            //요청
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
        case .denied:
            // 알럿 후 설정으로 이동
            showLocationSettingAlert()
            let defaultRegion = CLLocationCoordinate2D(latitude: 37.6544068, longitude: 127.0497957)
            defaultRegionSetting(defaultRegion)
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            print("하여튼 허용 안함")
        }
    }
    
    func defaultRegionSetting(_ center: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(region, animated: true)
    }
    
    func showLocationSettingAlert() {
        let alert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정->개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            
            if let setting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(setting)
            } else {
                print("설정으로 가줘")
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(goSetting)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    func setRegionAndAnnotation(_ center: CLLocationCoordinate2D) {
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(region, animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            setRegionAndAnnotation(center)
        }
        manager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationAuthorization()
    }
}

