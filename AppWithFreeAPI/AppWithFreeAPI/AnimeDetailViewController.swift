//
//  AnimeDetailViewController.swift
//  AppWithFreeAPI
//
//  Created by Алексей Каллистов on 05.04.2022.
//

import Foundation
import UIKit

class AnimeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

   // @IBOutlet weak var animeDetailLabel: UILabel!
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
        title = animeName
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
//        self.tableView.estimatedRowHeight = 80
//        self.tableView.rowHeight = UITableView.automaticDimension
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
        //cell.textLabel?.text = "Something"
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
