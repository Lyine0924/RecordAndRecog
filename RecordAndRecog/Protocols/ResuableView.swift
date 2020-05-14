//
//  ResuableView.swift
//  DRLemon
//
//  Created by Myeong Soo on 2020/04/23.
//  Copyright © 2020 Lemon Health Care. All rights reserved.
//

import UIKit

protocol ResuableView:NSObject {
    static var reuseIdentifier: String { get }
}

extension ResuableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ResuableView {
}

extension UICollectionReusableView:ResuableView {}

extension UITableView {
    func dequeueReusableCell<T:UITableViewCell>(for indexPath:IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable Cell")
        }
        return cell
    }
}


