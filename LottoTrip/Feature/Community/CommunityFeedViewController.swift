//
//  CommunityFeedViewController.swift
//  LottoTrip
//
//  운명 공동체 — 위치기반 숏폼 피드 + 실시간 채팅 진입.
//

import UIKit
import SnapKit

final class CommunityFeedViewController: BaseScrollViewController {

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
        let spacer = UIView()
        spacer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        let row = UIStackView(arrangedSubviews: [
            ChipView(text: "주변 숏폼", filled: true),
            ChipView(text: "인기"),
            ChipView(text: "팔로잉"),
            spacer
        ])
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
        return card
    }

    @objc private func openChat() {
        navigationController?.pushViewController(ChatRoomViewController(), animated: true)
    }
}
