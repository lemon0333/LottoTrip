//
//  CommonResponseDTO.swift
//  LottoTrip
//
//  API 명세서 "공통 Response" 형식.
//
//  성공:
//    { "status": 200, "data": {...}, "error": null }
//  실패:
//    { "status": 401, "data": null, "error": { "code": "AUTH_002", "message": "..." } }
//

import Foundation

/// 최상위 공통 응답 래퍼
public struct ApiResponse<T: Decodable>: Decodable {
    public let status: Int
    public let data: T?
    public let error: ApiErrorBody?
}

/// 공통 에러 바디
public struct ApiErrorBody: Decodable {
    public let code: String
    public let message: String
}

/// data 타입 무관하게 status/error 만 뽑아내는 경량 메타 디코더.
/// (에러 응답은 data 가 null 이라 `ApiResponse<T>` 디코딩이 실패할 수 있어 별도 사용)
public struct ApiEnvelopeMeta: Decodable {
    public let status: Int
    public let error: ApiErrorBody?
}

/// data 가 없는(=Void) 응답을 디코딩하기 위한 빈 모델. (로그아웃/삭제 등)
public struct EmptyResponse: Decodable {
    public init() {}
    public init(from decoder: Decoder) throws {}
}
