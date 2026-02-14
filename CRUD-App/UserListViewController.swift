//
//  UserListViewController.swift
//  CRUD-App
//

import UIKit

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView()
    private let addBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: nil,
        action: nil
    )
    private let logoutBarButtonItem = UIBarButtonItem(
        title: "退出",
        style: .plain,
        target: nil,
        action: nil
    )
    private var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUsers()
    }

    private func setupUI() {
        title = "Users"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = addBarButtonItem
        navigationItem.leftBarButtonItem = logoutBarButtonItem
        addBarButtonItem.target = self
        addBarButtonItem.action = #selector(addUserTapped)
        logoutBarButtonItem.target = self
        logoutBarButtonItem.action = #selector(logoutTapped)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadUsers() {
        Task {
            do {
                users = try await APIService.shared.fetchUsers()
                await MainActor.run {
                    tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    showAlert(message: "Failed to load users: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func logoutTapped() {
        APIService.shared.logout()
    }

    @objc private func addUserTapped() {
        let detailVC = UserDetailViewController()
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func deleteUser(at index: Int) {
        let user = users[index]
        Task {
            do {
                try await APIService.shared.deleteUser(id: user.id ?? 0)
                await MainActor.run {
                    users.remove(at: index)
                    tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
            } catch {
                await MainActor.run {
                    showAlert(message: "Failed to delete user: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = "\(user.name)\n\(user.email)"
        cell.textLabel?.numberOfLines = 0
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let detailVC = UserDetailViewController(user: user)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteUser(at: indexPath.row)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension UserListViewController: UserDetailViewControllerDelegate {
    func userDetailViewController(_ controller: UserDetailViewController, didSaveUser user: User) {
        loadUsers()
    }
}
