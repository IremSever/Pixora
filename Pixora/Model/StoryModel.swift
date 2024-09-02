//
//  StoryModel.swift
//  Pixora
//
//  Created by İrem Sever on 2.09.2024.
//

import Foundation

struct StoryModel: Codable {
    let story: Story
}

struct Story: Codable {
    let storyResponse: [StoryResponse]
}

struct StoryResponse: Codable {
    let user, userImage: String
    let storyDetails: [StoryDetail]
}

struct StoryDetail: Codable {
    let image, video, videoDuration, title, spot: String?
}
