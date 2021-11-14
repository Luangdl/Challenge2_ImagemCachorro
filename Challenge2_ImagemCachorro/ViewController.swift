//
//  ViewController.swift
//  Challenge2_ImagemCachorro
//
//  Created by Lucas Angeli Lima on 03/11/21.
//

import UIKit

enum DogError: Error {
    case badUrl
    case parseError
    case unknownError
    case otherError(Error)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var dogImageView: UIImageView!
    
    @IBAction func newDog(_ sender: Any) {
        self.getDogImage()
    }
    
    let urlDefault = "https://dog.ceo/api/breeds/image/random"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getDogImage()
    }
    
    func requestDogImage(completion: @escaping(Result<DogImage, DogError>) -> Void) {
        let session = URLSession.shared
        guard let url = URL(string: urlDefault) else { return }
        
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(DogError.otherError(error)))
            }
            guard let data = data else {
                completion(.failure(.unknownError))
                return
            }
            do {
                let dogImage = try JSONDecoder().decode(DogImage.self, from: data)
                completion(.success(dogImage))
            } catch {
                completion(.failure(.parseError))
            }
        }.resume()
    }
    
    func getDogImage() {
        requestDogImage { [weak self] result in
            switch result {
            case .success(let dog):
                guard let dogUwrapped = self?.dogImageView else {return}
                UIView.transition(with: dogUwrapped, duration: 0.5, options: .transitionFlipFromRight, animations: {
                    dogUwrapped.downloadImage(dog.message)
                }, completion: nil)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

extension UIImageView {
    func downloadImage(_ url: String) {
        let session = URLSession.shared
        guard let url = URL(string: url) else {
            return
        }
        
        session.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.sync {
                let image = UIImage(data: data)
                self?.image = image
            }
        }.resume()
    }

}

class DogImage: Codable {
    let message: String
}

