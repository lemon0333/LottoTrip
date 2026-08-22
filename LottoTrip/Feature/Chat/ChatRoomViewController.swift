//
//  ChatRoomViewController.swift
//  LottoTrip
//
//  운명 공동체 실시간 채팅 (STOMP 자리 — 지금은 목 메시지).
//

import UIKit
import SnapKit

final class ChatRoomViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let messageStack = UIStackView()
    private let inputBar = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ivory
        navigationItem.title = SampleData.chatRoom.title

        scrollView.showsVerticalScrollIndicator = false
        messageStack.axis = .vertical
        messageStack.spacing = 10
        messageStack.isLayoutMarginsRelativeArrangement = true
        messageStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        buildInputBar()

        view.addSubview(scrollView)
        view.addSubview(inputBar)
        scrollView.addSubview(messageStack)

        inputBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.height.equalTo(52)
        }
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(inputBar.snp.top).offset(-8)
        }
        messageStack.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        SampleData.chat.forEach { messageStack.addArrangedSubview(messageView($0)) }
    }

    private func messageView(_ msg: ChatMessageDTO) -> UIView {
        if msg.isSystem {
            let wrap = UIView()
            let pill = UIView()
            // 시스템 메시지 알약 배경 — 팔레트(tileEmpty)로 통일
            pill.backgroundColor = AppColor.tileEmpty
            pill.layer.cornerRadius = 12
            let label = UILabel.make(msg.text, font: AppFont.medium(11), color: AppColor.sub)
            pill.addSubview(label)
            label.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)) }
            wrap.addSubview(pill)
            pill.snp.makeConstraints { $0.centerX.top.bottom.equalToSuperview() }
            return wrap
        }

        let bubble = UIView()
        bubble.backgroundColor = msg.isMine ? AppColor.coral : .white
        bubble.layer.cornerRadius = 14
        if !msg.isMine { bubble.layer.borderWidth = 1; bubble.layer.borderColor = AppColor.line.cgColor }
        let text = UILabel.make(msg.text, font: AppFont.regular(14), color: msg.isMine ? .white : AppColor.ink)
        bubble.addSubview(text)
        text.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 13)) }
        bubble.snp.makeConstraints { $0.width.lessThanOrEqualTo(250) }

        let col = UIStackView()
        col.axis = .vertical
        col.spacing = 3
        col.alignment = msg.isMine ? .trailing : .leading
        if !msg.isMine { col.addArrangedSubview(UILabel.make(msg.sender, font: AppFont.medium(11), color: AppColor.sub)) }
        col.addArrangedSubview(bubble)

        let row = UIStackView()
        row.axis = .horizontal
        let spacer = UIView()
        spacer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        if msg.isMine { row.addArrangedSubview(spacer); row.addArrangedSubview(col) }
        else { row.addArrangedSubview(col); row.addArrangedSubview(spacer) }
        return row
    }

    private func buildInputBar() {
        inputBar.backgroundColor = .white
        inputBar.layer.cornerRadius = 26
        inputBar.layer.borderWidth = 1
        inputBar.layer.borderColor = AppColor.line.cgColor
        let placeholder = UILabel.make("메시지 입력...", font: AppFont.regular(14), color: AppColor.sub)
        let send = UIButton(type: .system)
        send.backgroundColor = AppColor.coral
        send.layer.cornerRadius = 18
        send.setAttributedTitle(NSAttributedString(string: "↑", attributes: [.font: AppFont.bold(16), .foregroundColor: UIColor.white]), for: .normal)
        inputBar.addSubview(placeholder)
        inputBar.addSubview(send)
        placeholder.snp.makeConstraints { $0.leading.equalToSuperview().inset(16); $0.centerY.equalToSuperview() }
        send.snp.makeConstraints { $0.trailing.equalToSuperview().inset(8); $0.centerY.equalToSuperview(); $0.size.equalTo(36) }
    }
}
