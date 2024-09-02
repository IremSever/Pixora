//
//  StoriesModel.swift
//  TurkuvazSDK
//
//  Created by İrem Sever on 21.07.2024.
//


import Foundation

struct StoriesModel: Codable {
    let stories: Stories
}

struct Stories: Codable {
    let storiesResponse: [StoriesResponse]
}

struct StoryResponse: Codable {
    let user, userImage: String
    let storyDetails: [StoryDetail]
}

struct StoryDetail: Codable {
    let image, video, videoDuration, title, spot: String?
}
