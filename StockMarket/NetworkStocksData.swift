//
//  NetworkStocksData.swift
//  Stocks
//
//  Created by Gleb on 14.02.2021.
//  Copyright © 2021 Gleb. All rights reserved.
//

//import Foundation
//
//
//struct Stocks {
//    let companySym: String
//    let companyName: String
//    let price: Double
//    let priceChange: Double
//
//    var companies = [String: Any]()
//
//    enum CodingKeys: String, CodingKey {
//        case companyName = "companyName"
//        case companySym = "symbol"
//        case price = "latestPrice"
//        case priceChange = "change"
//
//        case companies
//    }
//}
//
//extension Stocks: Decodable {
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        price = try values.decode(Double.self, forKey: .price)
//        priceChange = try values.decode(Double.self, forKey: .priceChange)
//        companySym = try values.decode(String.self, forKey: .companySym)
//        companyName = try values.decode(String.self, forKey: .companyName)
//    }
//}
//
//var companies = [String: Any]()
//
//func parseData(for symbol: String) {
//    let urlString = "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(token)"
//
//    if let url = URL(string: urlString) {
//        if let data = try? Data(contentsOf: url) {
//            // we're OK to parse!
//        }
//    }
//}
