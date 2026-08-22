//
//  NetworkManagerProtocol.swift
//  LottoTrip
//
//  제네릭 Moya 요청 실행기. 공통 응답(envelope) 검증/에러 매핑은
//  NetworkManagerExtension 의 기본 구현이 담당한다.
//

import Foundation
import Moya

protocol NetworkManager {
    associatedtype Endpoint: TargetType   // 도메인별 TargetType

    var provider: MoyaProvider<Endpoint> { get }

    /// 1. 필수 데이터 요청 (data 없으면 실패)
    func request<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )

    /// 2. 옵셔널 데이터 요청 (data 없어도 성공(nil))
    func requestOptional<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    )

    /// 3. 성공/실패만 확인 (data 무시 — 로그아웃/삭제 등)
    func requestStatusCode(
        target: Endpoint,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
}
