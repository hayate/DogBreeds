//
//  DogsAPI.swift
//  Dogs
//
//  Created by Andrea Belvedere on 2021/03/04.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import RxDataSources
import Nuke

/*
{'weight': {'imperial': '45 - 80', 'metric': '20 - 36'},
    'height': {'imperial': '20 - 27', 'metric': '51 - 69'},
    'id': 250,
    'name': 'Treeing Walker Coonhound',
    'breed_group': 'Hound',
    'life_span': '10 - 13 years',
    'temperament': 'Clever, Affectionate, Confident, Intelligent, Loving, Trainable',
    'reference_image_id': 'SkRpsgc47',
    'image': {'id': 'SkRpsgc47',
        'width': 1920,
        'height': 1080,
        'url': 'https://cdn2.thedogapi.com/images/SkRpsgc47.jpg'}}
 */

struct Image: Equatable, Codable {
    var id: String
    var width: Int
    var height: Int
    var url: String
}

struct Weight: Equatable, Codable {
    var imperial: String
    var metric: String
}

struct Height: Equatable, Codable {
    var imperial: String
    var metric: String
}

struct Dog: Equatable, Codable {
    var weight: Weight
    var height: Height
    var id: Int
    var name: String
    var breed_group: String?
    var life_span: String
    var temperament: String?
    var reference_image_id: String
    var image: Image
}

extension Dog: IdentifiableType {
    typealias Identity = Int

    var identity: Identity {
        return id
    }
}

struct SectionOfDog {
    var header: String = ""
    var items: [Item]

    var identity: String {
        return header
    }
}

extension SectionOfDog: AnimatableSectionModelType {
    typealias Item = Dog

    init(original: SectionOfDog, items: [Item]) {
        self = original
        self.items = items
    }
}


class DogsAPI {
    private static let Instance: DogsAPI = DogsAPI()

    public let dogs = BehaviorRelay<[Dog]>(value: [])
    public let error = BehaviorRelay<String?>(value: nil)

    private let preheater: ImagePreheater!
    private let apiURL: String = "https://api.thedogapi.com/v1/breeds"
    private let disposeBag = DisposeBag()

    private init() {
        self.preheater = ImagePreheater(pipeline: ImagePipeline.shared, destination: .memoryCache, maxConcurrentRequestCount: 10)
    }


    public static func getInstance() -> DogsAPI {
        return Instance
    }

    public func load() -> Void {
        let url = URL(string: apiURL)!
        var request = URLRequest(url: url)
        request.method = .get
        request.headers = [
            "X-Api-Key": Const.APIKey,
            "Accept": "application/json",
        ]

        RxAlamofire.requestJSON(request).subscribe(onNext: {(response, any) in
            if 200..<300 ~= response.statusCode {
                do {
                    let data = try JSONSerialization.data(withJSONObject: any)
                    let dogs = try JSONDecoder().decode([Dog].self, from: data)
                    self.dogs.accept(dogs)
                } catch let error {
                    self.error.accept(error.localizedDescription)
                }
            } else {
                self.error.accept("Error response from sever status code: \(response.statusCode)")
            }
        }, onError: {error in
            self.error.accept(error.localizedDescription)
        }).disposed(by: disposeBag)
    }

    public func startPrefetch(indexPaths: [IndexPath]) -> Void {
        let dogs = self.dogs.value
        let requests: [ImageRequest] = indexPaths.filter {
            dogs.indices.contains($0.item)
        }.map {index -> ImageRequest in
            let dog = dogs[index.item]
            let url = URL(string: dog.image.url)!

            return ImageRequest(url: url, processors: [], priority: .normal)
        }
        self.preheater.startPreheating(with: requests)
    }

    public func stopPrefetch(indexPaths: [IndexPath]) -> Void {
        let dogs = self.dogs.value
        let requests: [ImageRequest] = indexPaths.filter {
            dogs.indices.contains($0.item)
        }.map {index -> ImageRequest in
            let dog = dogs[index.item]
            let url = URL(string: dog.image.url)!

            return ImageRequest(url: url, processors: [], priority: .normal)
        }
        self.preheater.stopPreheating(with: requests)
    }
}
