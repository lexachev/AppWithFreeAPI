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
   
    func makeFavorite(cell: UITableViewCell){
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        let anime: AnimesTableViewCellViewModel = (isFiltering ? filteredViewModels : viewModels)[indexPathTapped.row]
        anime.isFavorite.toggle()
        let defaults = UserDefaults.standard
        var favoritesAnime = defaults.stringArray(forKey: "SavedStringArray") ?? [String]()
        if anime.isFavorite {
            favoritesAnime.append(anime.name)
        } else {
            if let index = favoritesAnime.firstIndex(of: anime.name) {
                favoritesAnime.remove(at: index)
            }
        }
        defaults.set(favoritesAnime, forKey: "SavedStringArray")
        tableView.reloadRows(at: [indexPathTapped], with: .fade)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Anime List"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        tableView.delegate = self
        tableView.dataSource = self
        let defaults = UserDefaults.standard
        let favoritesAnime = defaults.stringArray(forKey: "SavedStringArray") ?? [String]()
        AnimeFactAPI.shared.getAnimeList { [weak self] result in
            switch result {
               case .success(let animes):
                self?.viewModels = animes.compactMap({
                    AnimesTableViewCellViewModel(id: $0.anime_id, name: $0.anime_name, imageUrl: URL(string: $0.anime_img ?? ""), isFavorite: (favoritesAnime.contains($0.anime_name)))
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
        cell.accessoryView?.tintColor = .lightGray
        cell.link = self
        if isFiltering {
            cell.animeImageFavoriteView.image = UIImage(systemName: (filteredViewModels[indexPath.row].isFavorite ? "star.fill" : "star"))
            cell.configure(with: filteredViewModels[indexPath.row])
        } else {
            cell.accessoryView?.tintColor = .lightGray
            cell.animeImageFavoriteView.image = UIImage(systemName: (viewModels[indexPath.row].isFavorite ? "star.fill" : "star"))
            cell.configure(with: viewModels[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
