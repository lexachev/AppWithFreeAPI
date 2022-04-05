//
//  ViewController.swift
//  AppWithFreeAPI
//
//  Created by Алексей Каллистов on 04.04.2022.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(AnimesTableViewCell.self, forCellReuseIdentifier: AnimesTableViewCell.identifier)
        return table
    }()
    
    private var viewModels = [AnimesTableViewCellViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Anime List"
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        AnimeFactAPI.shared.getAnimeList { [weak self] result in
            switch result {
               case .success(let animes):
                self?.viewModels = animes.compactMap({
                    AnimesTableViewCellViewModel(id: $0.anime_id, name: $0.anime_name, imageUrl: URL(string: $0.anime_img ?? ""))
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
            withIdentifier: AnimesTableViewCell.identifier,
            for: indexPath
        ) as? AnimesTableViewCell else {
            fatalError()
        }
        //cell.textLabel?.text = "Something"
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showanimedetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AnimeDetailViewController {
            destination.animeName = viewModels[(tableView.indexPathForSelectedRow?.row)!].name
        }
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }
}

