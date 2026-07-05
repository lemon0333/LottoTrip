//
//  CommonResponseDTO.swift
//  LottoTrip
//
//  Archive-iOS 패턴: 공통 응답 래퍼 + 에러 응답.
//

import Foundation

// 최상위 응답 모델
public struct ApiResponse<T: Decodable>: Decodable {
    public let isSuccess: Bool
    public let code: String
    public let message: String
    public let result: T?
}

// 서버 에러 메시지 디코딩용
public struct ErrorResponse: Decodable {
    public let isSuccess: Bool?
    public let code: String?
    public let message: String?
}
