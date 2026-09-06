//
//  CommunityFeedViewController.swift
//  LottoTrip
//
//  운명 공동체 — 위치기반 숏폼 피드 + 실시간 채팅 진입.
//

import UIKit
import SnapKit

final class CommunityFeedViewController: BaseScrollViewController {

    // 필터 칩(주변 숏폼 / 인기 / 팔로잉) — 단일 선택 토글 관리
    private var filterChips: [FeedToggleChip] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "운명 공동체"

        contentStack.addArrangedSubview(headerRow("운명 공동체", right: "● LIVE", rightColor: AppColor.coral))
        contentStack.addArrangedSubview(UILabel.make("내 주변 같은 목적지 유저와 소통해요", font: AppFont.medium(13), color: AppColor.sub))
        contentStack.addArrangedSubview(chipRow())
        contentStack.addArrangedSubview(chatBanner())
        // 커뮤니티 API 미제공 — 피드는 empty state 로 표시
        contentStack.addArrangedSubview(emptyState())
    }

    // 주변 피드 empty-state (중앙 흐린 라벨)
    private func emptyState() -> UIView {
        let container = UIView()
        let label = UILabel.make("주변 피드가 아직 없어요", font: AppFont.medium(14), color: AppColor.sub, align: .center)
        container.addSubview(label)
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(56)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        return container
    }

    private func chipRow() -> UIStackView {
        // 첫 칩(주변 숏폼)만 선택된 상태로 시작
        filterChips = [
            FeedToggleChip(text: "주변 숏폼", selected: true),
            FeedToggleChip(text: "인기", selected: false),
            FeedToggleChip(text: "팔로잉", selected: false)
        ]
        filterChips.forEach { $0.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside) }

        let spacer = UIView()
        spacer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        let row = UIStackView(arrangedSubviews: filterChips as [UIView] + [spacer])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }

    private func chatBanner() -> UIView {
        let banner = UIView()
        banner.backgroundColor = AppColor.coral
        banner.layer.cornerRadius = 14
        let label = UILabel.make("운명 공동체 채팅방 입장", font: AppFont.bold(14), color: .white)
        let arrow = UILabel.make("→", font: AppFont.bold(16), color: .white)
        let row = UIStackView(arrangedSubviews: [label, arrow])
        row.axis = .horizontal
        row.alignment = .center
        banner.addSubview(row)
        row.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 13, left: 14, bottom: 13, right: 14)) }
        label.snp.makeConstraints { $0.width.lessThanOrEqualTo(290) }
        banner.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openChat)))
        banner.isUserInteractionEnabled = true
        return banner
    }

    @objc private func openChat() {
        navigationController?.pushViewController(ChatRoomViewController(), animated: true)
    }

    // 필터 칩 단일 선택 — 탭한 칩만 코랄로 채우고 나머지는 해제
    @objc private func filterTapped(_ sender: FeedToggleChip) {
        filterChips.forEach { $0.on = ($0 === sender) }
    }
}

// MARK: - FeedToggleChip
// ChipView와 동일한 룩을 갖되 탭으로 선택/해제되는 칩 (선택=코랄 채움)
private final class FeedToggleChip: UIControl {
    private let label = UILabel()

    var on: Bool { didSet { updateStyle() } }

    init(text: String, selected: Bool) {
        self.on = selected
        super.init(frame: .zero)
        layer.cornerRadius = 15
        layer.borderWidth = 1

        label.text = text
        label.font = AppFont.medium(13)
        label.isUserInteractionEnabled = false
        addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(13)
        }
        updateStyle()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func updateStyle() {
        backgroundColor = on ? AppColor.coral : AppColor.card
        layer.borderColor = (on ? AppColor.coral : AppColor.line).cgColor
        label.textColor = on ? .white : AppColor.sub
    }
}
