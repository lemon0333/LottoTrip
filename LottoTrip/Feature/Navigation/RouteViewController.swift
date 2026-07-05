//
//  RouteViewController.swift
//  LottoTrip
//
//  동선 최적화 — 뚜벅이(1km+무장애) / 자차(20km).
//

import UIKit
import SnapKit

final class RouteViewController: BaseScrollViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "동선 최적화"

        contentStack.addArrangedSubview(headerRow("동선 최적화", right: "새로고침 ↻"))
        contentStack.addArrangedSubview(FlowChipView(items: ["🚶 뚜벅이 · 1km", "🚗 자차 · 20km"], active: [0]))
        contentStack.addArrangedSubview(UILabel.make("뚜벅이 모드 · 역/터미널 1km + 무장애 정보 교차검증", font: AppFont.medium(12), color: AppColor.cafe))

        let map = UIView()
        map.backgroundColor = UIColor(hex: 0xD7E6D8)
        map.layer.cornerRadius = 14
        map.snp.makeConstraints { $0.height.equalTo(160) }
        let mapLabel = UILabel.make("네이버 지도 · 실시간 경로", font: AppFont.medium(13), color: AppColor.sub)
        map.addSubview(mapLabel)
        mapLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        contentStack.addArrangedSubview(map)

        let dest = UIStackView()
        dest.axis = .horizontal
        dest.distribution = .equalSpacing
        dest.addArrangedSubview(UILabel.make("→  강릉 아들바위공원", font: AppFont.bold(15), color: AppColor.ink))
        dest.addArrangedSubview(UILabel.make("2.4km", font: AppFont.medium(13), color: AppColor.sub))
        contentStack.addArrangedSubview(dest)

        contentStack.addArrangedSubview(routeRow("버스", "실시간 · 곧 도착", "202번 · 3분 후 도착", "35분", active: true))
        contentStack.addArrangedSubview(routeRow("도보", "무장애 ✓", "휠체어·유모차 접근 가능", "12분", active: false))
        contentStack.addArrangedSubview(routeRow("자차", "드라이브", "동해안 해안도로", "22분", active: false))

        let start = PrimaryButton(title: "안내 시작")
        contentStack.addArrangedSubview(start)
    }

    private func routeRow(_ mode: String, _ title: String, _ desc: String, _ time: String, active: Bool) -> UIView {
        let box = UIView()
        box.backgroundColor = active ? UIColor(hex: 0xFAEBE8) : .white
        box.layer.cornerRadius = 16
        box.layer.borderWidth = active ? 2 : 1
        box.layer.borderColor = (active ? AppColor.coral : AppColor.line).cgColor

        let icon = UILabel.make(mode, font: AppFont.bold(12), color: active ? .white : AppColor.cafe, align: .center)
        let iconWrap = UIView()
        iconWrap.backgroundColor = active ? AppColor.coral : AppColor.ivory
        iconWrap.layer.cornerRadius = 22
        iconWrap.addSubview(icon)
        icon.snp.makeConstraints { $0.center.equalToSuperview() }
        iconWrap.snp.makeConstraints { $0.size.equalTo(44) }

        let texts = UIStackView(arrangedSubviews: [
            UILabel.make(title, font: AppFont.bold(15), color: AppColor.ink),
            UILabel.make(desc, font: AppFont.medium(12), color: active ? AppColor.coral : AppColor.sub)
        ])
        texts.axis = .vertical
        texts.spacing = 3

        let timeLabel = UILabel.make(time, font: AppFont.bold(15), color: AppColor.ink)

        let row = UIStackView(arrangedSubviews: [iconWrap, texts, timeLabel])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        box.addSubview(row)
        row.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 16)) }
        texts.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        return box
    }
}
