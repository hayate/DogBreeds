//
//  FeedController.swift
//  Dogs
//
//  Created by Andrea Belvedere on 2021/03/04.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class FeedController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    public var indexPath: IndexPath!

    private var dataSource: RxTableViewSectionedAnimatedDataSource<SectionOfDog>!
    private let api: DogsAPI = DogsAPI.getInstance()
    private let disposeBag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if api.dogs.value.isEmpty {
            api.load()
        }

        setupUI()
        setupBinding()

        DispatchQueue.main.async {
            if let indexPath = self.indexPath {
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private func setupUI() -> Void {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UIScreen.main.bounds.height * 0.75
        tableView.separatorStyle = .none

        dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfDog>(
            configureCell: {dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: FeedViewCell.Identifier, for: indexPath) as! FeedViewCell
                cell.dog.accept(item)
                return cell
            }
        )
    }

    private func setupBinding() -> Void {
        api.dogs.map {items in
            [SectionOfDog(items: items)]
        }.bind(to: tableView.rx.items(dataSource: self.dataSource)).disposed(by: disposeBag)
    }
}
