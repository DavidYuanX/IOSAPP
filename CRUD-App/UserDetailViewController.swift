//
//  UserDetailViewController.swift
//  CRUD-App
//

import UIKit

protocol UserDetailViewControllerDelegate: AnyObject {
    func userDetailViewController(_ controller: UserDetailViewController, didSaveUser user: User)
}

class UserDetailViewController: UIViewController {

    weak var delegate: UserDetailViewControllerDelegate?

    private let user: User?
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let nameTextField = UITextField()
    private let emailTextField = UITextField()
    private let phoneTextField = UITextField()
    private let saveButton = UIButton(type: .system)

    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let phoneLabel = UILabel()

    init(user: User? = nil) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let user = user {
            populateFields(with: user)
        }
    }

    private func setupUI() {
        title = user == nil ? "Add User" : "Edit User"
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(phoneLabel)
        contentView.addSubview(phoneTextField)
        contentView.addSubview(saveButton)

        // Setup labels
        nameLabel.text = "Name:"
        emailLabel.text = "Email:"
        phoneLabel.text = "Phone:"

        [nameLabel, emailLabel, phoneLabel].forEach {
            $0.font = .systemFont(ofSize: 16, weight: .medium)
        }

        // Setup text fields
        [nameTextField, emailTextField, phoneTextField].forEach {
            $0.borderStyle = .roundedRect
            $0.font = .systemFont(ofSize: 16)
        }

        emailTextField.keyboardType = .emailAddress
        phoneTextField.keyboardType = .phonePad

        // Setup save button
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        // Constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Name
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),

            // Email
            emailLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            // Phone
            phoneLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            phoneLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            phoneLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            phoneTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 8),
            phoneTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            phoneTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            phoneTextField.heightAnchor.constraint(equalToConstant: 44),

            // Save Button
            saveButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func populateFields(with user: User) {
        nameTextField.text = user.name
        emailTextField.text = user.email
        phoneTextField.text = user.phone
    }

    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter a name")
            return
        }

        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter an email")
            return
        }

        let newUser = User(id: user?.id, name: name, email: email, phone: phoneTextField.text)

        Task {
            do {
                let savedUser: User
                if let _ = user?.id {
                    savedUser = try await APIService.shared.updateUser(newUser)
                } else {
                    savedUser = try await APIService.shared.createUser(newUser)
                }

                await MainActor.run {
                    delegate?.userDetailViewController(self, didSaveUser: savedUser)
                    navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    showAlert(message: "Failed to save user: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
