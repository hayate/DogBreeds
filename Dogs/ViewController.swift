//
//  ViewController.swift
//  Dogs
//
//  Created by Andrea Belvedere on 2021/03/04.
//

import UIKit
import RxSwift
import RxDataSources


class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let api: DogsAPI = DogsAPI.getInstance()
    private let cellSpacing: CGFloat = 1.0
    private let disposeBag = DisposeBag()
    private var dataSource: RxCollectionViewSectionedAnimatedDataSource<SectionOfDog>!
    private var indexPath: IndexPath!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        api.load()
        setupUI()
        setupBinding()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? FeedController {
            controller.indexPath = self.indexPath
        }
    }

    private func setupUI() -> Void {
        title = "Dog Breeds"

        collectionView.rx.setDelegate(self).disposed(by: disposeBag)

        dataSource = RxCollectionViewSectionedAnimatedDataSource<SectionOfDog>(
            configureCell: {dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DogGridViewCell.Identifier, for: indexPath) as! DogGridViewCell
                cell.dog.accept(item)
                return cell
            }
        )
    }

    private func setupBinding() -> Void {
        api.dogs.map {dogs in
            return [SectionOfDog(items: dogs)]
        }.bind(to: collectionView.rx.items(dataSource: self.dataSource)).disposed(by: disposeBag)

        collectionView.rx.prefetchItems.subscribe(onNext: {items in
            self.api.startPrefetch(indexPaths: items)
        }).disposed(by: disposeBag)

        collectionView.rx.cancelPrefetchingForItems.subscribe(onNext: {items in
            self.api.stopPrefetch(indexPaths: items)
        }).disposed(by: disposeBag)

        collectionView.rx.itemSelected.subscribe(onNext: {indexPath in
            self.indexPath = indexPath
            self.performSegue(withIdentifier: "toFeedController", sender: self)
        }).disposed(by: disposeBag)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        self.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        self.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side: CGFloat = (collectionView.frame.width - (cellSpacing * 2)) / 3
        return CGSize(width: side, height: side)
    }
}
