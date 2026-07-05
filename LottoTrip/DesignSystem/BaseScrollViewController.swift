//
//  BaseScrollViewController.swift
//  LottoTrip
//
//  세로 스크롤 + contentStack(좌우 20 여백) 공통 베이스.
//

import UIKit
import SnapKit

class BaseScrollViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ivory
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 28, right: 20)
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
    }

    /// 좌(제목)·우(액세서리) 헤더 행
    func headerRow(_ title: String, right: String? = nil, rightColor: UIColor = AppColor.sub) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        row.addArrangedSubview(UILabel.make(title, font: AppFont.bold(21), color: AppColor.ink))
        if let right { row.addArrangedSubview(UILabel.make(right, font: AppFont.medium(13), color: rightColor)) }
        return row
    }
}
