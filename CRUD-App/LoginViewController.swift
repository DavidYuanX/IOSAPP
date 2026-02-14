//
//  LoginViewController.swift
//  CRUD-App
//

import UIKit

class LoginViewController: UIViewController {

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "用户登录"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let usernameField: UITextField = {
        let f = UITextField()
        f.placeholder = "用户名"
        f.borderStyle = .roundedRect
        f.autocapitalizationType = .none
        f.autocorrectionType = .no
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let passwordField: UITextField = {
        let f = UITextField()
        f.placeholder = "密码"
        f.borderStyle = .roundedRect
        f.isSecureTextEntry = true
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("登录", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    var onLoginSuccess: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(usernameField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(loginButton)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            usernameField.heightAnchor.constraint(equalToConstant: 44),
            passwordField.heightAnchor.constraint(equalToConstant: 44),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }

    @objc private func loginTapped() {
        let username = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""

        guard !username.isEmpty, !password.isEmpty else {
            showAlert(message: "请输入用户名和密码")
            return
        }

        loginButton.isEnabled = false
        Task {
            do {
                try await APIService.shared.login(username: username, password: password)
                await MainActor.run {
                    loginButton.isEnabled = true
                    onLoginSuccess?()
                }
            } catch {
                await MainActor.run {
                    loginButton.isEnabled = true
                    showAlert(message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
