//
//  FeedViewCell.swift
//  Dogs
//
//  Created by Andrea Belvedere on 2021/03/04.
//

import UIKit
import RxSwift
import RxCocoa
import Nuke


class FeedViewCell: UITableViewCell {
    public static let Identifier: String = "FeedViewCell"

    public let dog = BehaviorRelay<Dog?>(value: nil)

    private var nameLabel: UILabel!
    private var dogImageView: UIImageView!
    private var descriptionTitleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private let disposeBag = DisposeBag()


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        setupUI()
        setupBinding()
    }

    override func prepareForReuse() {
        dog.accept(nil)
    }

    private func setupUI() -> Void {
        selectionStyle = .none
        
        nameLabel = UILabel()
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        descriptionTitleLabel = UILabel()
        descriptionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTitleLabel.text = "Description"
        descriptionTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .thin)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping

        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20),
            nameLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -20),

            descriptionTitleLabel.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20),
            descriptionTitleLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20),
            descriptionLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
    }

    private func setupBinding() -> Void {
        dog.subscribe(onNext: {dog in
            if let dog = dog {
                let size: CGSize = self.scaledImageSize(width: dog.image.width, height: dog.image.height)
                self.layoutUI(dog: dog, size: size)
                self.loadImage(dog.image, size: size)
            } else {
                self.unlayout()
            }
        }).disposed(by: disposeBag)
    }

    private func layoutUI(dog: Dog, size: CGSize) -> Void {
        dogImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        dogImageView.translatesAutoresizingMaskIntoConstraints = false
        dogImageView.contentMode = .scaleAspectFit
        contentView.addSubview(dogImageView)

        if let breed = dog.breed_group {
            nameLabel.text = "\(breed) - \(dog.name)"
        } else {
            nameLabel.text = dog.name
        }
        descriptionTitleLabel.text = "Description"
        descriptionLabel.text = dog.temperament

        let dogImageHeightConstraint = dogImageView.heightAnchor.constraint(equalToConstant: size.height)
        dogImageHeightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            dogImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            dogImageView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor),
            dogImageView.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor),
            dogImageHeightConstraint,
            dogImageView.bottomAnchor.constraint(equalTo: descriptionTitleLabel.topAnchor, constant: -10),
        ])
    }

    private func loadImage(_ image: Image, size: CGSize) -> Void {
        let request = ImageRequest(
            url: URL(string: image.url)!,
            processors: [ImageProcessors.Resize(size: size, contentMode: .aspectFit)],
            priority: .high
        )
        Nuke.loadImage(with: request, into: self.dogImageView)
    }

    private func unlayout() -> Void {
        if let dogImageView = self.dogImageView {
            dogImageView.removeFromSuperview()
            self.dogImageView.image = nil
        }
    }

    private func scaledImageSize(width: Int, height: Int) -> CGSize {
        let ratio: CGFloat = CGFloat(width) / CGFloat(height)
        let w: CGFloat = CGFloat(UIScreen.main.bounds.width)
        let h = w / ratio
        return CGSize(width: w, height: h)
    }
}
