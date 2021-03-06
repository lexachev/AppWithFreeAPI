//
//  AnimeDetailViewController.swift
//  AppWithFreeAPI
//
//  Created by Алексей Каллистов on 05.04.2022.
//

import UIKit

class AnimeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var animeName: String?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(AnimeFactsTableViewCell.self, forCellReuseIdentifier: AnimeFactsTableViewCell.identifier)
        return table
    }()
    
    private var viewModels = [AnimeFactsTableViewCellViewModel]()
    
    private let animeDetailTitleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .medium)
        label.text = "Anime Details"
        label.frame = CGRect(x: 10, y: 200, width: 300, height: 50)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = (animeName ?? "No name").replacingOccurrences(of: "_", with: " ")
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        AnimeFactAPI.shared.getAnimeFacts(animeName: animeName ?? "") { [weak self] result in
            switch result {
               case .success(let animes):
                self?.viewModels = animes.compactMap({
                    AnimeFactsTableViewCellViewModel(id: $0.fact_id, fact: $0.fact)
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AnimeFactsTableViewCell.identifier,
            for: indexPath
        ) as? AnimeFactsTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
