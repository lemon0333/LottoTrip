//
//  ResultViewController.swift
//  LottoTrip
//
//  추천 결과 — 강원 숨은명소 + 채울 퍼즐 조각 배지.
//

import UIKit
import SnapKit

final class ResultViewController: BaseScrollViewController {

    private let dest = SampleData.destination

    /// 슬롯 draw 로 받은 실제 서버 결과 (없으면 SampleData 로 표시)
    private let result: SlotDrawResponseDTO?

    init(result: SlotDrawResponseDTO? = nil) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 표시값 (서버 결과 우선, 없으면 SampleData 폴백)

    private var placeName: String { result?.place.name ?? dest.name }
    private var categoryText: String {
        // category 는 백엔드 한글 displayName 문자열 그대로 표시
        if let category = result?.place.category, !category.isEmpty, category != "UNKNOWN" { return category }
        return dest.category
    }
    private var locationText: String {
        // draw 응답엔 주소가 없으므로(상세조회에만 있음) 카테고리·지역 느낌으로 표시
        if let category = result?.place.category, !category.isEmpty { return "TourAPI · \(category)" }
        return "TourAPI · 강원 강릉시"
    }
    private var metaLine: String {
        if let km = result?.place.distanceKm { return "거리 \(Int(km.rounded()))km" }
        return "예산 ~\(dest.budget / 10000)만원"
    }
    private var missionTitle: String { result?.mission?.title ?? dest.missionTitle }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "추천 결과"

        contentStack.addArrangedSubview(headerRow("운명의 목적지 도착!", right: "다시 SPIN ↻", rightColor: AppColor.coral))
        contentStack.addArrangedSubview(mapView())
        contentStack.addArrangedSubview(resultCard())
        contentStack.addArrangedSubview(missionBadge())

        let actions = UIStackView(arrangedSubviews: [
            makeButton("길찾기", bg: AppColor.ink, fg: .white, action: #selector(goRoute)),
            makeButton("코스에 저장", bg: .white, fg: AppColor.coral, bordered: true, action: #selector(save))
        ])
        actions.axis = .horizontal
        actions.spacing = 10
        actions.distribution = .fillEqually
        contentStack.addArrangedSubview(actions)

        let shortform = PrimaryButton(title: "숏폼으로 남기기", bg: AppColor.cafe, fg: .white)
        shortform.addTarget(self, action: #selector(goShortform), for: .touchUpInside)
        contentStack.addArrangedSubview(shortform)
    }

    private func mapView() -> UIView {
        let map = UIView()
        map.backgroundColor = UIColor(hex: 0xD7E6D8)
        map.layer.cornerRadius = 14
        let pin = UIView()
        pin.backgroundColor = AppColor.coral
        pin.layer.cornerRadius = 22
        pin.layer.borderWidth = 3
        pin.layer.borderColor = UIColor.white.cgColor
        let star = UILabel.make("★", font: AppFont.bold(18), color: .white, align: .center)
        pin.addSubview(star)
        star.snp.makeConstraints { $0.center.equalToSuperview() }
        let label = UILabel.make(locationText, font: AppFont.medium(13), color: AppColor.sub)
        map.addSubview(pin)
        map.addSubview(label)
        map.snp.makeConstraints { $0.height.equalTo(170) }
        pin.snp.makeConstraints { $0.size.equalTo(44); $0.centerX.equalToSuperview(); $0.centerY.equalToSuperview().offset(-14) }
        label.snp.makeConstraints { $0.top.equalTo(pin.snp.bottom).offset(8); $0.centerX.equalToSuperview() }
        // 지도/장소 탭 → 목적지 상세(정보/메뉴/후기)
        map.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goDetail)))
        return map
    }

    private func resultCard() -> CardView {
        let card = CardView()
        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 8
        let name = UILabel.make(placeName, font: AppFont.bold(20), color: AppColor.ink)
        let hiddenChip = ChipView(text: "숨은 명소", filled: true)
        titleRow.addArrangedSubview(name)
        titleRow.addArrangedSubview(hiddenChip)
        let spacer = UIView(); spacer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        titleRow.addArrangedSubview(spacer)

        let category = UILabel.make(categoryText, font: AppFont.medium(13), color: AppColor.cafe)

        let meta = UIStackView()
        meta.axis = .horizontal
        meta.spacing = 14
        meta.addArrangedSubview(UILabel.make("리뷰 적음 ✦", font: AppFont.bold(13), color: AppColor.coral))
        meta.addArrangedSubview(UILabel.make(metaLine, font: AppFont.regular(13), color: AppColor.sub))
        let metaSpacer = UIView(); metaSpacer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        meta.addArrangedSubview(metaSpacer)

        // 퍼즐 조각 연동 배지
        let piece = pieceBadge("이 장소는 ‘강릉’ 조각을 채워요")

        card.addArranged(titleRow, category, meta, piece)
        return card
    }

    private func pieceBadge(_ text: String) -> UIView {
        let badge = UIView()
        badge.backgroundColor = AppColor.lime.withAlphaComponent(0.15)
        badge.layer.cornerRadius = 10
        let label = UILabel.make("🧩 " + text, font: AppFont.bold(13), color: UIColor(hex: 0x3E7A18))
        badge.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)) }
        return badge
    }

    private func missionBadge() -> UIView {
        let badge = UIView()
        badge.backgroundColor = UIColor(hex: 0xFAEBE8)
        badge.layer.cornerRadius = 12
        let label = UILabel.make("🎲 운명 미션 · \(missionTitle)", font: AppFont.bold(13), color: AppColor.coral)
        badge.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)) }
        return badge
    }

    private func makeButton(_ title: String, bg: UIColor, fg: UIColor, bordered: Bool = false, action: Selector) -> PrimaryButton {
        let b = PrimaryButton(title: title, bg: bg, fg: fg, bordered: bordered)
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    @objc private func goRoute() {
        navigationController?.pushViewController(
            RouteFindViewController(destinationName: placeName), animated: true)
    }
    @objc private func goDetail() {
        navigationController?.pushViewController(DestinationDetailViewController(), animated: true)
    }
    @objc private func goShortform() { navigationController?.pushViewController(ShortformEditorViewController(), animated: true) }

    /// 코스에 저장 — 슬롯(slotId)을 여행 코스에 추가
    @objc private func save() {
        guard let slotId = result?.slotId else {
            showAlert(title: "안내", message: "저장할 슬롯 결과가 없습니다.")
            return
        }
        APIClient.shared.course.add(slotId: slotId) { [weak self] outcome in
            switch outcome {
            case .success:
                self?.showAlert(title: "저장 완료", message: "여행 코스에 담았어요.")
            case .failure(let error):
                if error.errorCode == .alreadyAdded {
                    self?.showAlert(title: "안내", message: "이미 코스에 담긴 장소예요.")
                } else {
                    self?.showAlert(title: "저장 실패", message: error.description)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // MARK: - enum → 한글 라벨

    private static func budgetLabel(_ level: BudgetLevel) -> String {
        switch level {
        case .low:    return "~5만원"
        case .medium: return "~10만원"
        case .high:   return "20만원+"
        }
    }
}
