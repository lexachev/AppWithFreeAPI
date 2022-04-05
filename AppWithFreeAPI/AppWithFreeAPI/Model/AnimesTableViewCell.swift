//
//  AnimesTableViewCell.swift
//  AppWithFreeAPI
//
//  Created by Алексей Каллистов on 04.04.2022.
//

import UIKit

class AnimesTableViewCellViewModel {
    let id: Int
    let name: String
    let imageUrl: URL?
    var imageData: Data? = nil
    
    init(
        id: Int,
        name: String,
        imageUrl: URL?
    ){
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }
}

class AnimesTableViewCell: UITableViewCell {
    static let identifier = "AnimesTableViewCell"
    
    private let animeTitleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .medium)
        return label
    }()
    
    private let animeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(animeTitleLabel)
        contentView.addSubview(animeImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animeTitleLabel.frame = CGRect(x: 175, y: 0, width: contentView.frame.size.width - 175, height: contentView.frame.size.height)
        animeImageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animeTitleLabel.text = nil
        animeImageView.image = nil
    }
    
    func configure(with viewModel: AnimesTableViewCellViewModel){
        animeTitleLabel.text = viewModel.name.replacingOccurrences(of: "_", with: " ")
        
        if let data = viewModel.imageData {
            animeImageView.image = UIImage(data: data)
        } else if let url = viewModel.imageUrl {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else { return }
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.animeImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}
