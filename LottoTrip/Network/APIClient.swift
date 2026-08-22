//
//  APIClient.swift
//  LottoTrip
//
//  전 도메인 서비스 진입점(파사드). ViewController 등에서 APIClient.shared 로 접근한다.
//
//  예)
//    APIClient.shared.slot.draw(latitude: lat, longitude: lng, budget: .medium, transport: .car) { result in
//        switch result {
//        case .success(let slot): // slot.place, slot.mission ...
//        case .failure(let error):
//            if error.errorCode == .noPlaceFound { /* 반경 확장 안내 */ }
//            print(error.description)
//        }
//    }
//

import Foundation

final class APIClient {
    static let shared = APIClient()

    let auth    = AuthService()
    let slot    = SlotService()
    let course  = CourseService()
    let mission = MissionService()
    let video   = VideoService()
    let chat    = ChatService()
    let health  = HealthService()

    private init() {}
}
