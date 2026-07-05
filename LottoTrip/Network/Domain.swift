//
//  Domain.swift
//  LottoTrip
//
//  Archive-iOS 패턴: baseURL + feature별 URL 상수.
//

import Foundation

public struct Domain {
    public static let baseURL      = "https://lottotrip.example.com"   // 플레이스홀더 (서버 붙일 때 교체)
    public static let authURL      = "\(baseURL)/auth"       // 인증/로그인
    public static let recommendURL = "\(baseURL)/recommend"  // 슬롯 랜덤 추천 (TourAPI)
    public static let puzzleURL    = "\(baseURL)/puzzle"     // 강원 지도 퍼즐
    public static let missionURL   = "\(baseURL)/mission"    // 운명 미션
    public static let communityURL = "\(baseURL)/community"  // 운명 공동체 피드/채팅
}
