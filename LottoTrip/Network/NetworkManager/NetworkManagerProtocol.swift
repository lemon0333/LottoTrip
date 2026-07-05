//
//  NetworkManagerProtocol.swift
//  LottoTrip
//
//  Archive-iOS 패턴 그대로: 제네릭 Moya 요청 실행기.
//

import Foundation
import Moya

protocol NetworkManager {
    associatedtype Endpoint: TargetType   // feature별 TargetType

    var provider: MoyaProvider<Endpoint> { get }

    // 1. 일반 데이터 요청 (T, 필수값)
    func request<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )

    // 2. 일반 데이터 요청 (T?, 옵셔널)
    func requestOptional<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    )

    // 3. 상태 코드만 확인
    func requestStatusCode(
        target: Endpoint,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
}
