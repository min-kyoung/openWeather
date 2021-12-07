//
//  ErrorMessage.swift
//  openWeather
//
//  Created by 노민경 on 2021/12/07.
//

import Foundation

// json 데이터를 맵핑하기 위해 codable 채택
struct ErrorMessage: Codable {
    let message: String
}
