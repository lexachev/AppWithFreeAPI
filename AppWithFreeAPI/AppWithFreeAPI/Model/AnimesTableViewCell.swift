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
    var isFavorite: Bool = false
    
    init(
        id: Int,
        name: String,
        imageUrl: URL?,
        isFavorite: Bool
    ){
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.isFavorite = isFavorite
    }
}

class AnimesTableViewCell: UITableViewCell {
    static let identifier = "AnimesTableViewCell"
    var link: ViewController?
    private let animeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(animeTitleLabel)
        contentView.addSubview(animeImageView)
        contentView.addSubview(animeImageFavoriteView)
        animeImageFavoriteView.translatesAutoresizingMaskIntoConstraints = false
        animeImageFavoriteView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        animeImageFavoriteView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        //let origImage = UIImage(named: "fav_star")
        //let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        let favoriteButton = UIButton(type: .system)
        favoriteButton.frame = CGRect(x:  contentView.frame.size.width, y: 0, width: 30, height: contentView.frame.size.height)
        //favoriteButton.setTitle("+", for: .normal)
        favoriteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        //favoriteButton.setImage(tintedImage, for: .normal)
        //favoriteButton.tintColor = UIColor.red
        favoriteButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        accessoryView = favoriteButton
        
    }
    
    @objc private func pressed() {
        link?.makeFavorite(cell: self)
    }

    private let animeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var animeImageFavoriteView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animeTitleLabel.frame = CGRect(x: 160, y: 0, width: contentView.frame.size.width - 175, height: contentView.frame.size.height)
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
