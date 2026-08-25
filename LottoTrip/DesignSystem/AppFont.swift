//
//  AppFont.swift
//  LottoTrip
//

import UIKit

/// 앱 전역 폰트 = 원티드 산스(Wanted Sans). 디자이너 치수 가이드 기준.
/// 번들 폰트가 없으면 시스템 폰트로 안전 폴백.
enum AppFont {
    static func bold(_ size: CGFloat)     -> UIFont { wanted("WantedSans-Bold",     size, .bold) }
    static func semibold(_ size: CGFloat) -> UIFont { wanted("WantedSans-SemiBold", size, .semibold) }
    static func medium(_ size: CGFloat)   -> UIFont { wanted("WantedSans-Medium",   size, .medium) }
    static func regular(_ size: CGFloat)  -> UIFont { wanted("WantedSans-Regular",  size, .regular) }

    private static func wanted(_ name: String, _ size: CGFloat, _ fallback: UIFont.Weight) -> UIFont {
        UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: fallback)
    }
}

extension UILabel {
    /// 간단 생성 헬퍼
    static func make(_ text: String, font: UIFont, color: UIColor, align: NSTextAlignment = .left, lines: Int = 0) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.textAlignment = align
        label.numberOfLines = lines
        return label
    }
}
