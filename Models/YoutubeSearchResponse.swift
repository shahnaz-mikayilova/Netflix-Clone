//
//  YoutubeSearchResponse.swift
//  Netflix-Clone
//
//  Created by Shahnaz on 22.01.26.
//

import Foundation

struct YoutubeSearchResponse : Codable {
    let items: [VideoElement]
    
}

struct VideoElement : Codable {
    let id: IdVideoElement
}

struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}
