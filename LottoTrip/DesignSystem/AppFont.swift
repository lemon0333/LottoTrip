//
//  AppFont.swift
//  LottoTrip
//

import UIKit

enum AppFont {
    static func bold(_ size: CGFloat)     -> UIFont { .systemFont(ofSize: size, weight: .bold) }
    static func semibold(_ size: CGFloat) -> UIFont { .systemFont(ofSize: size, weight: .semibold) }
    static func medium(_ size: CGFloat)   -> UIFont { .systemFont(ofSize: size, weight: .medium) }
    static func regular(_ size: CGFloat)  -> UIFont { .systemFont(ofSize: size, weight: .regular) }
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
