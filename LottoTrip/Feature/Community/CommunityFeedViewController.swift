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
    // 피드 카드 → 장소명 매핑 (탭 시 상세 안내에 사용)
    private var cardPlaces: [UIView: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "운명 공동체"

        contentStack.addArrangedSubview(headerRow("운명 공동체", right: "● LIVE", rightColor: AppColor.coral))
        contentStack.addArrangedSubview(UILabel.make("내 주변 2km · 같은 목적지 유저 12명", font: AppFont.medium(13), color: AppColor.sub))
        contentStack.addArrangedSubview(chipRow())
        contentStack.addArrangedSubview(chatBanner())
        SampleData.feed.forEach { contentStack.addArrangedSubview(feedCard($0)) }
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
        let label = UILabel.make("강릉 아들바위行 운명 공동체 (8명) 입장", font: AppFont.bold(14), color: .white)
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

    private func feedCard(_ post: CommunityPostDTO) -> CardView {
        let card = CardView(spacing: 10, padding: 12)
        let image = UIView()
        image.backgroundColor = UIColor(hex: 0xC7D4DA)
        image.layer.cornerRadius = 12
        image.snp.makeConstraints { $0.height.equalTo(150) }

        let meta = UIStackView()
        meta.axis = .horizontal
        meta.distribution = .equalSpacing
        meta.addArrangedSubview(UILabel.make(post.placeName, font: AppFont.bold(15), color: AppColor.ink))
        meta.addArrangedSubview(UILabel.make(post.distanceText, font: AppFont.medium(12), color: AppColor.coral))

        let stats = UIStackView()
        stats.axis = .horizontal
        stats.spacing = 14
        stats.addArrangedSubview(UILabel.make("♥ \(post.likes)", font: AppFont.medium(13), color: AppColor.sub))
        stats.addArrangedSubview(UILabel.make("💬 \(post.comments)", font: AppFont.medium(13), color: AppColor.sub))
        let statsSpacer = UIView()
        statsSpacer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        stats.addArrangedSubview(statsSpacer)

        card.addArranged(image, meta, stats)

        // 카드 탭 → 해당 장소 상세 안내 (숏폼 게시물이므로 알림으로 처리)
        cardPlaces[card] = post.placeName
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:))))
        card.isUserInteractionEnabled = true
        return card
    }

    @objc private func openChat() {
        navigationController?.pushViewController(ChatRoomViewController(), animated: true)
    }

    // 필터 칩 단일 선택 — 탭한 칩만 코랄로 채우고 나머지는 해제
    @objc private func filterTapped(_ sender: FeedToggleChip) {
        filterChips.forEach { $0.on = ($0 === sender) }
    }

    // 피드 카드 탭 → 장소명으로 상세 진입 예고 알림
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view, let place = cardPlaces[view] else { return }
        let alert = UIAlertController(title: place, message: "곧 상세가 열려요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
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
