//
//  LogConsoleViewController.swift
//  Axxyl
//
//  Created by Mangesh on 9/21/25.
//


import UIKit
import MessageUI

public final class LogConsoleViewController: UIViewController {

    private let textView = UITextView()
    private let topBar = UIStackView()
    private var observer: NSObjectProtocol?

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupTextView()
        setupTopBar()
        refreshText()
        observer = NotificationCenter.default.addObserver(forName: Logger.newLogNotification, object: nil, queue: .main) { [weak self] notif in
            if let line = notif.object as? String {
                self?.appendLine(line)
            } else {
                self?.refreshText()
            }
        }
    }

    deinit {
        if let o = observer { NotificationCenter.default.removeObserver(o) }
    }

    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = UIColor.systemBackground
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
    }

    private func setupTopBar() {
        topBar.axis = .horizontal
        topBar.alignment = .center
        topBar.distribution = .equalSpacing
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)

        let close = makeButton(title: "Close", selector: #selector(closeTapped))
        let clear = makeButton(title: "Clear", selector: #selector(clearTapped))
        let share = makeButton(title: "Share", selector: #selector(shareTapped))
        let email = makeButton(title: "Email", selector: #selector(emailTapped))

        topBar.addArrangedSubview(close)
        topBar.addArrangedSubview(clear)
        topBar.addArrangedSubview(share)
        topBar.addArrangedSubview(email)

        NSLayoutConstraint.activate([
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            topBar.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func makeButton(title: String, selector: Selector) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.addTarget(self, action: selector, for: .touchUpInside)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return b
    }

//    private func appendLine(_ line: String) {
//        textView.textStorage.append(NSAttributedString(string: line))
//        scrollToBottom()
//    }

    private func appendLine(_ line: String) {
        let attributed = attributedLine(line)
        textView.textStorage.append(attributed)
        scrollToBottom()
    }
    
    private func attributedLine(_ line: String) -> NSAttributedString {
        let color: UIColor

        if line.contains("[ERROR]") {
            color = .systemRed
        } else if line.contains("[WARN]") {
            color = .systemOrange
        } else if line.contains("[DEBUG]") {
            color = .systemGray
        } else if line.contains("[MISC]") {
            color = .green
        } else {
            color = .label // default (info)
        }

        return NSAttributedString(
            string: line,
            attributes: [.foregroundColor: color]
        )
    }
    
    private func refreshText() {
        let fullText = Logger.shared.readEntireLog()
        let lines = fullText.components(separatedBy: "\n")
        let attrText = NSMutableAttributedString()

        for l in lines {
            if !l.isEmpty {
                attrText.append(attributedLine(l + "\n"))
            }
        }

        textView.attributedText = attrText
        scrollToBottom()
    }

    private func scrollToBottom() {
        let range = NSRange(location: textView.text.count, length: 0)
        textView.scrollRangeToVisible(range)
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        // if this controller is presented modally
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            // otherwise, if embedded in its own window, remove that window:
            if let win = view.window, win.windowLevel.rawValue > UIWindow.Level.normal.rawValue {
                win.isHidden = true
            } else {
                dismiss(animated: true)
            }
        }
    }

    @objc private func clearTapped() {
        let alert = UIAlertController(title: "Clear logs?", message: "This will erase the current log file.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            Logger.shared.clearLogs()
            self.textView.text = ""
        }))
        present(alert, animated: true)
    }

    @objc private func shareTapped() {
        let fileURL = Logger.shared.currentLogFileURL()
        let items: [Any] = [fileURL]
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        av.popoverPresentationController?.sourceView = view
        present(av, animated: true)
    }

    @objc private func emailTapped() {
        let fileURL = Logger.shared.currentLogFileURL()
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setSubject("App logs")
            composer.setMessageBody("Attached app log.", isHTML: false)
            if let data = try? Data(contentsOf: fileURL) {
                composer.addAttachmentData(data, mimeType: "text/plain", fileName: fileURL.lastPathComponent)
            }
            present(composer, animated: true)
        } else {
            // fallback: share sheet
            let av = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            av.popoverPresentationController?.sourceView = view
            present(av, animated: true)
        }
    }
}

extension LogConsoleViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
