//
//  SlotService.swift
//  LottoTrip
//
//  랜덤 장소(슬롯) 도메인 서비스.
//

import Foundation
import Moya

final class SlotService: NetworkManager {
    typealias Endpoint = SlotTargetType
    let provider: MoyaProvider<SlotTargetType>

    init(provider: MoyaProvider<SlotTargetType> = MoyaProvider<SlotTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    /// 슬롯 돌리기 — GPS·예산(원)·이동수단 기반 랜덤 목적지 + 미션.
    /// - Parameters:
    ///   - budget: 예산 원 정수(0 이상)
    ///   - accessible: 무장애 필터 (nil=미적용)
    ///   - contentTypeId: 장소종류 필터 문자열 (nil=전체; 숙박은 서버가 항상 제외)
    func draw(latitude: Double, longitude: Double, budget: Int, transport: TransportType,
              accessible: Bool? = nil, contentTypeId: String? = nil,
              completion: @escaping (Result<SlotDrawResponseDTO, NetworkError>) -> Void) {
        let dto = SlotDrawRequestDTO(latitude: latitude, longitude: longitude,
                                     budget: budget, transport: transport,
                                     accessible: accessible, contentTypeId: contentTypeId)
        request(target: .draw(dto), decodingType: SlotDrawResponseDTO.self, completion: completion)
    }

    /// 슬롯 결과 상세 조회 (주소·소개·홈페이지 포함)
    func result(slotId: Int,
                completion: @escaping (Result<SlotResultResponseDTO, NetworkError>) -> Void) {
        request(target: .result(slotId: slotId), decodingType: SlotResultResponseDTO.self, completion: completion)
    }
}
