//
//  UITableView+STAbout.swift
//  STAboutKit
//

import UIKit

extension UITableViewCell {
    static var stIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    func stDequeueCell<T: UITableViewCell>(type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(
            withIdentifier: type.stIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Failed to dequeue cell: \(type.stIdentifier)")
        }
        return cell
    }
}
