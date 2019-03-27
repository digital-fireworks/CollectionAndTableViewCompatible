//
//  AutolayoutTableView.swift
//  TableViewCompatible
//
//  Created by Fredrik Nannestad on 26/10/2016.
//  Copyright © 2016 Fredrik Nannestad. All rights reserved.
//

import UIKit

extension UITableView {
    
    func enableAutolayoutForCellHeights(estimatedRowHeight: CGFloat = 44) {
        self.estimatedRowHeight = estimatedRowHeight
        self.rowHeight = UITableView.automaticDimension
    }
    
}

class AutolayoutTableView: UITableView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.enableAutolayoutForCellHeights()
    }
    
}
