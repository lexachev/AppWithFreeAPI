//
//  ViewController.swift
//  AppWithFreeAPI
//
//  Created by Алексей Каллистов on 04.04.2022.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(AnimesTableViewCell.self, forCellReuseIdentifier: AnimesTableViewCell.identifier)
        return table
    }()
    
    private var viewModels = [AnimesTableViewCellViewModel]()
    private var filteredViewModels = [AnimesTableViewCellViewModel]()
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Anime List"
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
        if isFiltering {
            return filteredViewModels.count
        }
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
        if isFiltering {
            cell.configure(with: filteredViewModels[indexPath.row])
        } else {
            cell.configure(with: viewModels[indexPath.row])
        }
        
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
            if isFiltering {
                destination.animeName = filteredViewModels[(tableView.indexPathForSelectedRow?.row)!].name
            } else {
                destination.animeName = viewModels[(tableView.indexPathForSelectedRow?.row)!].name
            }
        }
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }
    
    
}

extension ViewController {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text! )
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredViewModels = viewModels.filter({ (anime: AnimesTableViewCellViewModel) -> Bool in
            return anime.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
}
