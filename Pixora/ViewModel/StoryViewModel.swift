//
//  StoryViewModel.swift
//  Pixora
//
//  Created by İrem Sever on 2.09.2024.
//

import Foundation

class StoryViewModel {
    var storyData: [StoryResponse] = []
    
    func parseJSON(resourceName: String, completion: @escaping (Bool) -> Void) {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "json") else {
            print("JSON file not found in bundle")
            completion(false)
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(StoryModel.self, from: data)
            handleResponse(response)
            completion(true)
        } catch {
            print("JSON conversion error: \(error)")
            completion(false)
        }
    }
    
    func loadJson(filename fileName: String) -> [StoryModel]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([StoryModel].self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    private func handleResponse(_ storyModel: StoryModel) {
        self.storyData = storyModel.story.storyResponse
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return storyData.count
    }
    
    func cellForRowAt(indexPath: IndexPath) -> StoryResponse {
        return storyData[indexPath.row]
    }
    
    func getStory(at index: Int) -> StoryResponse? {
        guard index >= 0 && index < storyData.count else { return nil }
        return storyData[index]
    }
}
