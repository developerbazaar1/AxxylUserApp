//
//  ConsoleOverlay.swift
//  Axxyl
//
//  Created by Mangesh on 9/21/25.
//


import UIKit

public final class ConsoleOverlay {
    public static let shared = ConsoleOverlay()
    private init() {}

    private var buttonWindow: UIWindow?
    private var consoleWindow: UIWindow?
    private weak var attachedScene: UIWindowScene?

    /// Call once at app start (e.g. SceneDelegate or SwiftUI App onAppear).
    /// Consider enabling only in DEBUG builds.
    public func enable() {
        DispatchQueue.main.async {
            guard self.buttonWindow == nil else { return }
            // pick an active scene
            if let scene = (UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene) ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene) {
                self.attachedScene = scene
                self.createButton(in: scene)
            }
        }
    }

    private func createButton(in scene: UIWindowScene) {
        let size: CGFloat = 56
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: scene.screen.bounds.width - size - 16,
                              y: size + 15,
                              width: size,
                              height: size)
        window.backgroundColor = .clear
        window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue + 1)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear

        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 0, width: size, height: size)
        btn.layer.cornerRadius = size/2
        btn.setTitle("Log", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.92)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowRadius = 6
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.translatesAutoresizingMaskIntoConstraints = true

        // pan to move
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        btn.addGestureRecognizer(pan)

        vc.view.addSubview(btn)
        window.rootViewController = vc
        window.isHidden = false

        self.buttonWindow = window
    }

    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        guard let btn = g.view, let win = buttonWindow else { return }
        let translation = g.translation(in: win)
        g.setTranslation(.zero, in: win)
        var newCenter = CGPoint(x: btn.center.x + translation.x, y: btn.center.y + translation.y)
        // bounds clamp
        let halfW = btn.bounds.width/2
        let halfH = btn.bounds.height/2
        newCenter.x = max(halfW, min(win.bounds.width - halfW, newCenter.x))
        newCenter.y = max(halfH, min(win.bounds.height - halfH, newCenter.y))
        btn.center = newCenter
    }

    @objc private func buttonTapped() {
        guard consoleWindow == nil else {
            hideConsole()
            return
        }
        showConsole()
    }

    private func showConsole() {
        guard let scene = attachedScene else { return }
        let win = UIWindow(windowScene: scene)
        let vc = LogConsoleViewController()
        win.rootViewController = vc
        win.frame = scene.screen.bounds
        win.backgroundColor = .systemBackground
        win.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue + 2)
        win.isHidden = false
        consoleWindow = win
    }

    private func hideConsole() {
        consoleWindow?.isHidden = true
        consoleWindow = nil
    }
}
