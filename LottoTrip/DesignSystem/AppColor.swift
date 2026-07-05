//
//  AppColor.swift
//  LottoTrip
//
//  레퍼런스 팔레트: Coral / Dusty Pink / Lime Green / Yellow Green / Ivory / Cafe Au Lait
//

import UIKit

enum AppColor {
    static let coral        = UIColor(hex: 0xE07A6F)
    static let dustyPink    = UIColor(hex: 0xD8A99B)
    static let lime         = UIColor(hex: 0x5FB52E)
    static let yellowGreen  = UIColor(hex: 0xA4C73A)
    static let ivory        = UIColor(hex: 0xF2EADC)
    static let cafe         = UIColor(hex: 0xA07D63)

    static let ink          = UIColor(hex: 0x2B2B2E)
    static let sub          = UIColor(hex: 0x736B66)
    static let line         = UIColor(hex: 0xDAD5CC)
    static let card         = UIColor.white
    static let tileEmpty    = UIColor(hex: 0xE6E1D8)

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
