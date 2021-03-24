//
//  StocksCell.swift
//  Stocks
//
//  Created by Глеб Шевченко on 09.03.2021.
//  Copyright © 2021 Gleb. All rights reserved.
//

import UIKit

class StocksCell: UITableViewCell {
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style , reuseIdentifier: reuseIdentifier)
        
//        backgroundColor = .red
        
        let starButton = UIButton(type: .system)
        starButton.setTitle("SOME", for: .normal)
        
        starButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
        accessoryView = starButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
