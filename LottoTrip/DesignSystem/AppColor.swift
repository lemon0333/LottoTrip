//
//  AppColor.swift
//  LottoTrip
//
//  레퍼런스 팔레트: Coral / Dusty Pink / Lime Green / Yellow Green / Ivory / Cafe Au Lait
//

import UIKit

enum AppColor {
    static let coral        = UIColor(hex: 0xF66053)   // 디자이너 지정 색
    static let dustyPink    = UIColor(hex: 0xD8A99B)
    static let lime         = UIColor(hex: 0x5FB52E)
    static let yellowGreen  = UIColor(hex: 0xA4C73A)
    /// 화면 기본 배경 — 피그마 기준 흰색 (기존 베이지 #F2EADC 에서 변경)
    static let ivory        = UIColor.white
    static let cafe         = UIColor(hex: 0xA07D63)

    static let ink          = UIColor(hex: 0x2B2B2E)
    static let sub          = UIColor(hex: 0x8E8E93)   // 중립 회색 (기존 베이지끼 #736B66 에서 변경)
    static let line         = UIColor(hex: 0xE5E5E5)   // 중립 구분선
    static let card         = UIColor.white
    static let tileEmpty    = UIColor(hex: 0xEAEBEC)   // 피그마 플레이스홀더 회색

    /// 강원 8권역 퍼즐 조각 색 (완성 시)
    static let pieceColors: [UIColor] = [coral, yellowGreen, dustyPink, lime, cafe, UIColor(hex: 0xF5C542), coral, lime]
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
