//
//  ViewController.swift
//  Stocks
//
//  Created by Gleb on 30.01.2021.
//  Copyright © 2021 Gleb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var companies = [String: Any]()
    var isOn: Bool = false
    var row = UserDefaults.standard.integer(forKey: "pickerViewRow")

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companySymLabel: UILabel!
    @IBOutlet weak var companyPrice: UILabel!
    @IBOutlet weak var companyPriceChange: UILabel!
    @IBOutlet weak var companyLogo: UIImageView!
    
    // ---------------------------------- //
    // - - - - - -  Button - - - - - - -  //
    // ---------------------------------- //
    
    @IBAction func actionButton(_ sender: UIButton) {
        
        let newValue = !sender.isSelected
        sender.isSelected = newValue
        UserDefaults.standard.set(newValue, forKey: "isSaved")
        /*
        setButtonBackGround(view: sender, on: #imageLiteral(resourceName: "star2"), off: #imageLiteral(resourceName: "star"), onOffStatus: isOn)

        UserDefaults.standard.set(companies, forKey: "companyName")
        UserDefaults.standard.set(self.row, forKey: "pickerViewRow")
        print(UserDefaults.standard.integer( forKey: "pickerViewRow"))
        */
    }
    
    func setButtonBackGround(view: UIButton, on: UIImage, off: UIImage, onOffStatus: Bool ) {
         switch onOffStatus {
              case true:
                   view.setImage(on, for: .normal)
              default:
                   view.setImage(off, for: .normal)
         }
    }

    
    // MARK: - Networking 
    func parseQuote(form data: Data) {
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObj as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySym = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double else { return print("invalid")
            }
            DispatchQueue.main.async { [weak self] in
                self?.displayStockInfo(companyName: companyName,
                                       companySym: companySym,
                                       price: price,
                                       priceChange: priceChange)
            }
        } catch {
            self.errorHandler(withTitle: "JSON error", andMessage: "error with json data: " + error.localizedDescription)
        }
    }

    ///- for dynamic list of stocks
    func parseCompanies(from data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
    
            guard
                let json = jsonObject as? [[String: Any]] else {
                self.errorHandler(withTitle: "Network error", andMessage: "No network")
                return print("Invalid JSON")
            }
            for symbolObject in json {
                guard
                    let companyName = symbolObject["companyName"] as? String,
                    let companySymbol = symbolObject["symbol"] as? String else { return print("Invalid JSON") }
                
                companies[companyName] = companySymbol
            }
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.companyPickerView.reloadAllComponents()
                self?.requestQuoteUpdate()
            }
            
        } catch {
            UIViewController().errorHandler(withTitle: "JSON error", andMessage: "error with json data: " + error.localizedDescription)
        }
    }
    
    ///- red/ blue color change
    private func displayStockInfo(companyName: String,
                                  companySym: String,
                                  price: Double,
                                  priceChange: Double) {
        
        activityIndicator.stopAnimating()
        companyNameLabel.text = companyName
        companySymLabel.text = companySym
        companyPrice.text = "\(price)"
        companyPriceChange.text = "\(priceChange)"
        
        if(priceChange < 0) {
            self.companyPriceChange.textColor = UIColor.red
        } else if (priceChange > 0) {
            self.companyPriceChange.textColor = UIColor.green
        } else {
            self.companyPriceChange.textColor = UIColor.black
        }
    }
    
        
    private func requestQuote(for symbol: String) {
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(token)") else { return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
            (response as? HTTPURLResponse)?.statusCode == 200,
                error == nil {
                self.parseQuote(form: data)
            } else {
                self.errorHandler(withTitle: "Network error", andMessage: "No network")
                return
            }
        }
        dataTask.resume()
    }
    
    ///- for dynamic list of stocks
    private func requestCompanies() {
        activityIndicator.startAnimating()

        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/market/collection/list?collectionName=mostactive&token=\(token)&listLimit=25") else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                    (response as? HTTPURLResponse)?.statusCode == 200,
                    error == nil {
                self.parseCompanies(from: data)
            } else {
                self.errorHandler(withTitle: "Network error", andMessage: "No network")
            }
        }
        dataTask.resume()
    }
    
    func requestQuoteUpdate() {
        activityIndicator.startAnimating()
        companyNameLabel.text = "-"
        companySymLabel.text = "-"
        companyPrice.text = "-"
        companyPriceChange.text = "-"
        companyPriceChange.textColor = UIColor.black
        
        let selectedRow = companyPickerView.selectedRow(inComponent: 0)
        let selectedSym = Array(companies.values)[selectedRow]
        
        requestQuote(for: selectedSym as! String)
        companyLogo.image = UIImage(url: URL(string: "https://storage.googleapis.com/iex/api/logos/\(selectedSym).png"))
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        requestQuoteUpdate()
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.cyan.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0,y: 0)
        gradientLayer.endPoint = CGPoint(x: 1,y: 1)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        companyLogo.layer.cornerRadius = companyLogo.frame.size.width / 2
        companyLogo.clipsToBounds = true

        companyPickerView.dataSource = self
        companyPickerView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        
        requestCompanies()
    }
}


extension ViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.keys.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(companies.keys)[row]
    }
}

// MARK: - error
extension UIViewController {

  func errorHandler(withTitle title: String, andMessage message: String) {
         DispatchQueue.main.async {
             let ok = UIAlertController(title: title, message: message, preferredStyle: .alert)
             ok.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
             
             self.present(ok, animated: true)
         }
     }
}

// MARK: - logo
extension UIImage {
    
    convenience init?(url: URL?) {
        guard let url = url else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            UIViewController().errorHandler(withTitle: "JSON error", andMessage: "error with json data: " + error.localizedDescription)
            return nil
        }
    }
}
