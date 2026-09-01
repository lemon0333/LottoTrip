//
//  KakaoLoginManager.swift
//  LottoTrip
//
//  카카오 로그인 래퍼. Info.plist 의 네이티브 앱 키가 있어야 활성화된다.
//  로그인 성공 시 카카오 access token 을 반환 → 서버 /auth/login 의 providerToken 으로 전달.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

enum KakaoLogin {

    /// Info.plist 의 네이티브 앱 키. 미설정(빈 값/플레이스홀더)이면 nil → 카카오 로그인 비활성.
    static var nativeKey: String? {
        let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String ?? ""
        let trimmed = key.trimmingCharacters(in: .whitespaces)
        return (trimmed.isEmpty || trimmed.contains("$(")) ? nil : trimmed
    }

    static var isConfigured: Bool { nativeKey != nil }

    /// 앱 시작 시 1회 초기화 (키 없으면 아무것도 안 함)
    static func initializeIfPossible() {
        guard let key = nativeKey else { return }
        KakaoSDK.initSDK(appKey: key)
    }

    /// 카카오 로그인 → 성공 시 accessToken 반환.
    /// KakaoTalk 앱이 있으면 앱 로그인, 없으면 계정(웹) 로그인.
    static func login(completion: @escaping (Result<String, Error>) -> Void) {
        let handler: (OAuthToken?, Error?) -> Void = { token, error in
            if let error { completion(.failure(error)); return }
            guard let token else {
                completion(.failure(NSError(domain: "kakao", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "카카오 토큰을 받지 못했습니다."])))
                return
            }
            completion(.success(token.accessToken))
        }
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk(completion: handler)
        } else {
            UserApi.shared.loginWithKakaoAccount(completion: handler)
        }
    }
}
