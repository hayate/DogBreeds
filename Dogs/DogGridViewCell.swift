//
//  DogGridViewCell.swift
//  Dogs
//
//  Created by Andrea Belvedere on 2021/03/04.
//

import UIKit
import RxSwift
import RxCocoa
import Nuke


class DogGridViewCell: UICollectionViewCell {
    public static let Identifier: String = "DogGridViewCell"

    private let disposeBag = DisposeBag()
    private var imageView: UIImageView!

    public let dog = BehaviorRelay<Dog?>(value: nil)


    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
        setupBinding()
    }

    private func setupUI() -> Void {
        imageView = UIImageView(frame: contentView.frame)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
        ])
    }

    private func setupBinding() -> Void {
        dog.skip(1).subscribe(onNext: {dog in
            if let dog = dog {
                self.loadImage(dog: dog)
            }
        }).disposed(by: disposeBag)
    }

    private func loadImage(dog: Dog) -> Void {
        let url = URL(string: dog.image.url)!
        let request = ImageRequest(url: url)

        Nuke.loadImage(with: request, into: imageView)
    }
}
