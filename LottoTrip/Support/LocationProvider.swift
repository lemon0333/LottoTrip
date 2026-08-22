//
//  LocationProvider.swift
//  LottoTrip
//
//  슬롯 draw 에 필요한 현재 좌표를 1회성으로 얻는다.
//  권한 거부/미설정/시뮬레이터 등으로 좌표를 못 얻으면 기본 좌표(강원 강릉)로 폴백한다.
//

import CoreLocation

final class LocationProvider: NSObject, CLLocationManagerDelegate {
    static let shared = LocationProvider()

    /// 기본 좌표 — 강원 강릉 (백엔드 강원권 데이터 기준)
    static let fallback = CLLocationCoordinate2D(latitude: 37.7519, longitude: 128.8761)

    private let manager = CLLocationManager()
    private var handler: ((CLLocationCoordinate2D) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// 현재 좌표 요청 (실패 시 fallback). 콜백은 항상 메인 스레드에서 1회 호출.
    func current(_ completion: @escaping (CLLocationCoordinate2D) -> Void) {
        // 스크린샷/미리보기용 디버그 훅: FIXED_COORD="lat,lng" 이면 권한 요청 없이 고정 좌표 사용
        if let fixed = ProcessInfo.processInfo.environment["FIXED_COORD"] {
            let parts = fixed.split(separator: ",").compactMap { Double($0) }
            if parts.count == 2 {
                DispatchQueue.main.async { completion(CLLocationCoordinate2D(latitude: parts[0], longitude: parts[1])) }
                return
            }
        }

        handler = completion

        // 시뮬레이터 등에서 위치 응답이 오지 않는 경우 대비 타임아웃 폴백
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.finish(LocationProvider.fallback)
        }

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            finish(LocationProvider.fallback)
        }
    }

    private func finish(_ coordinate: CLLocationCoordinate2D) {
        guard let handler else { return }
        self.handler = nil
        DispatchQueue.main.async { handler(coordinate) }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            finish(LocationProvider.fallback)
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        finish(locations.first?.coordinate ?? LocationProvider.fallback)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(LocationProvider.fallback)
    }
}
