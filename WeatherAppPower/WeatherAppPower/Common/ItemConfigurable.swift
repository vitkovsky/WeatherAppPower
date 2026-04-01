//
//  ItemConfigurable.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import Foundation

protocol ItemConfigurable: AnyObject {
    associatedtype ItemType
    func configure(with item: ItemType)
}
