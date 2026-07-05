//
//  NetworkError.swift
//  LottoTrip
//
//  Archive-iOS 패턴 그대로.
//

import Foundation

public enum NetworkError: Error {
    case urlError                        // URL 에러
    case dataNil                         // 데이터 없음
    case invalidResponse                 // 유효하지 않은 응답
    case failToDecode(String)            // 디코딩 에러
    case serverError(String)             // 서버 에러
    case networkError(message: String)   // 네트워크 에러 (연결 끊김/타임아웃 등)
    case requestFailed(String)           // 요청 실패
    case otherMoyaError(String?)         // 기타 에러
}

extension NetworkError {
    var description: String {
        switch self {
        case .urlError:                    return "URL이 올바르지 않습니다."
        case .dataNil:                     return "데이터가 없습니다."
        case .invalidResponse:             return "응답 값이 유효하지 않습니다."
        case .failToDecode(let message):   return "디코딩 에러: \(message)"
        case .serverError(let message):    return message
        case .networkError(let message):   return message
        case .requestFailed(let message):  return "요청 실패: \(message)"
        case .otherMoyaError(let message): return message ?? "알 수 없는 오류가 발생했습니다."
        }
    }
}
