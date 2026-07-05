//
//  PreferenceViewController.swift
//  LottoTrip
//
//  여행 취향 설정 (예산·이동수단·스타일·누구와).
//

import UIKit

final class PreferenceViewController: BaseScrollViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "여행 취향 설정"
        contentStack.spacing = 18
        contentStack.addArrangedSubview(headerRow("여행 취향 설정", right: "STEP 1/2"))
        contentStack.addArrangedSubview(section("이동수단", ["도보", "대중교통", "자차", "자전거"], active: [1]))
        contentStack.addArrangedSubview(section("여행 날짜", ["이번 주말", "평일 휴가", "당일치기", "1박 2일"], active: [0]))
        contentStack.addArrangedSubview(section("여행 스타일", ["액티비티", "힐링", "맛집투어", "감성카페", "포토스팟"], active: [3, 4]))
        contentStack.addArrangedSubview(section("누구와", ["혼자", "친구", "가족", "연인"], active: [1]))
        contentStack.addArrangedSubview(section("예산", ["~5만원", "~10만원", "~20만원", "제한 없음"], active: [1]))

        let next = PrimaryButton(title: "다음")
        next.addTarget(self, action: #selector(done), for: .touchUpInside)
        contentStack.addArrangedSubview(next)
    }

    private func section(_ title: String, _ items: [String], active: Set<Int>) -> UIStackView {
        let head = UILabel.make(title, font: AppFont.bold(15), color: AppColor.ink)
        let flow = FlowChipView(items: items, active: active)
        let col = UIStackView(arrangedSubviews: [head, flow])
        col.axis = .vertical
        col.spacing = 10
        return col
    }

    @objc private func done() { SceneDelegate.switchRoot(to: RootTabBarController()) }
}
