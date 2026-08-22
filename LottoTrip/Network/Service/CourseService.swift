//
//  CourseService.swift
//  LottoTrip
//
//  여행 코스 도메인 서비스.
//

import Foundation
import Moya

final class CourseService: NetworkManager {
    typealias Endpoint = CourseTargetType
    let provider: MoyaProvider<CourseTargetType>

    init(provider: MoyaProvider<CourseTargetType> = MoyaProvider<CourseTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    /// 코스 조회 — 현재 코스에 담긴 목적지 목록
    func items(completion: @escaping (Result<[CourseItemDTO], NetworkError>) -> Void) {
        request(target: .items, decodingType: [CourseItemDTO].self, completion: completion)
    }

    /// 코스에 추가 — 슬롯(slotId)을 코스에 담기
    func add(slotId: Int,
             completion: @escaping (Result<CourseItemDTO, NetworkError>) -> Void) {
        request(target: .add(slotId: slotId), decodingType: CourseItemDTO.self, completion: completion)
    }

    /// 코스 항목 삭제
    func delete(itemId: Int,
                completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(target: .deleteItem(itemId: itemId), completion: completion)
    }
}
