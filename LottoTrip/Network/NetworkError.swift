//
//  NetworkError.swift
//  LottoTrip
//
//  API 명세서 "에러 코드 모음"(백엔드 ErrorCode enum) 기준.
//  서버가 내려주는 error.code 문자열을 타입 안전한 ErrorCode 로 매핑한다.
//

import Foundation

// MARK: - 서버 에러 코드 (명세서 ErrorCode enum 미러)

public enum ErrorCode: String {
    // 공통
    case badRequest          = "COMMON_400"   // 400 잘못된 요청
    case unauthorized        = "COMMON_401"   // 401 인증 필요
    case internalError       = "COMMON_500"   // 500 서버 내부 오류
    case serviceUnavailable  = "COMMON_503"   // 503 소셜 서버 장애 등 일시적 불가
    // 인증
    case invalidProviderToken = "AUTH_001"    // 401 소셜 토큰 유효하지 않음
    case invalidRefreshToken  = "AUTH_002"    // 401 리프레시 토큰 만료/무효
    // 슬롯
    case noPlaceFound        = "SLOT_001"     // 404 반경 내 후보 장소 없음
    case resultNotFound      = "SLOT_002"     // 404 슬롯 결과 없음
    // 코스
    case alreadyAdded        = "COURSE_001"   // 409 이미 코스에 담긴 항목
    case itemNotFound        = "COURSE_002"   // 404 코스 항목 없음
    // 미션
    case missionNotFound     = "MISSION_001"  // 404 미션 없음
    case alreadyCompleted    = "MISSION_002"  // 409 이미 완료된 미션
    case verificationFailed  = "MISSION_003"  // 422 위치 인증 실패
    // 영상
    case jobNotFound         = "VIDEO_001"    // 404 렌더링 작업 없음
    case invalidFileCount    = "VIDEO_002"    // 400 업로드 파일 개수 초과
    // 채팅
    case notRoomMember       = "CHAT_001"     // 403 채팅방 멤버 아님
    case roomNotFound        = "CHAT_002"     // 404 채팅방 없음

    /// 명세서에 없는(또는 신규) 코드
    case unknown             = "UNKNOWN"

    public init(code: String) {
        self = ErrorCode(rawValue: code) ?? .unknown
    }

    /// 명세서에 정의된 기본 한글 메시지
    public var defaultMessage: String {
        switch self {
        case .badRequest:           return "잘못된 요청입니다."
        case .unauthorized:         return "인증이 필요합니다."
        case .internalError:        return "서버 내부 오류입니다."
        case .serviceUnavailable:   return "일시적으로 서비스에 연결할 수 없습니다. 잠시 후 다시 시도해주세요."
        case .invalidProviderToken: return "소셜 토큰이 유효하지 않습니다."
        case .invalidRefreshToken:  return "리프레시 토큰이 만료되었거나 유효하지 않습니다."
        case .noPlaceFound:         return "반경 내 후보 장소가 없습니다."
        case .resultNotFound:       return "슬롯 결과를 찾을 수 없습니다."
        case .alreadyAdded:         return "이미 코스에 담긴 항목입니다."
        case .itemNotFound:         return "코스 항목을 찾을 수 없습니다."
        case .missionNotFound:      return "미션을 찾을 수 없습니다."
        case .alreadyCompleted:     return "이미 완료된 미션입니다."
        case .verificationFailed:   return "위치 인증에 실패했습니다."
        case .jobNotFound:          return "렌더링 작업을 찾을 수 없습니다."
        case .invalidFileCount:     return "업로드 가능한 파일 개수를 벗어났습니다."
        case .notRoomMember:        return "채팅방 멤버가 아닙니다."
        case .roomNotFound:         return "채팅방을 찾을 수 없습니다."
        case .unknown:              return "알 수 없는 오류가 발생했습니다."
        }
    }

    /// 인증 토큰 관련 오류인지 (→ 토큰 갱신 트리거 판단용)
    public var isAuthError: Bool {
        switch self {
        case .unauthorized, .invalidProviderToken, .invalidRefreshToken: return true
        default: return false
        }
    }
}

// MARK: - 네트워크 계층 통합 에러

public enum NetworkError: Error {
    case urlError                                       // URL 구성 실패
    case dataNil                                        // 성공 응답이나 data 가 없음
    case invalidResponse                                // HTTP 응답 형식 오류
    case failToDecode(String)                           // 디코딩 실패
    /// 서버가 내려준 표준 에러 (envelope.error)
    case server(code: ErrorCode, rawCode: String, message: String, status: Int)
    case networkError(message: String)                  // 연결 끊김/타임아웃 등
    case requestFailed(String)                          // 요청 실패
    case otherMoyaError(String?)                        // 기타

    /// 편의: 서버 에러의 타입 코드 (서버 에러가 아니면 nil)
    public var errorCode: ErrorCode? {
        if case let .server(code, _, _, _) = self { return code }
        return nil
    }

    /// 편의: 토큰 갱신이 필요한 상황인지
    public var requiresTokenRefresh: Bool {
        errorCode?.isAuthError ?? false
    }
}

extension NetworkError {
    /// 사용자 노출용 메시지
    public var description: String {
        switch self {
        case .urlError:                     return "URL이 올바르지 않습니다."
        case .dataNil:                      return "데이터가 없습니다."
        case .invalidResponse:              return "응답 값이 유효하지 않습니다."
        case .failToDecode(let message):    return "디코딩 에러: \(message)"
        case let .server(_, _, message, _): return message
        case .networkError(let message):    return message
        case .requestFailed(let message):   return "요청 실패: \(message)"
        case .otherMoyaError(let message):  return message ?? "알 수 없는 오류가 발생했습니다."
        }
    }
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? { description }
}
