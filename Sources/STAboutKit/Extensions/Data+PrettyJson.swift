//
//  Data+PrettyJson.swift
//  STAboutKit
//

import Foundation

extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self),
              let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
