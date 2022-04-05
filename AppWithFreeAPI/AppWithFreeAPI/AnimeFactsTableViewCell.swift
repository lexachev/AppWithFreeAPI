//
//  AnimeFactsTableViewCell.swift
//  AppWithFreeAPI
//
//  Created by Алексей Каллистов on 05.04.2022.
//

import UIKit
class AnimeFactsTableViewCellViewModel {
    let id: Int
    let fact: String
    
    init(
        id: Int,
        fact: String
    ){
        self.id = id
        self.fact = fact
    }
}

class AnimeFactsTableViewCell: UITableViewCell {
    static let identifier = "AnimeFactsTableViewCell"
    
    private let animeFactLabel: UITextView = {
       let label = UITextView()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        //label.numberOfLines = 10
        //label.numberOfLines = 0
        //label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(animeFactLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animeFactLabel.frame = CGRect(x: 10, y: 10, width: contentView.frame.size.width - 10, height: contentView.frame.size.height - 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animeFactLabel.text = nil
    }
    
    func configure(with viewModel: AnimeFactsTableViewCellViewModel){
        animeFactLabel.text = viewModel.fact
    }
}
