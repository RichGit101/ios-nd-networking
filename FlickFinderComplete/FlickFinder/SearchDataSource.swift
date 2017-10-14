//
//  SearchDataSource.swift
//  FlickFinder
//
//  Created by Jarrod Parkes on 10/3/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import Foundation

// MARK: - SearchDataSourceDelegate

protocol SearchDataSourceDelegate {
    func searchDataSourceDidFetchPhoto(searchDataSource: SearchDataSource)
    func searchDataSource(_ searchDataSource: SearchDataSource, didFailWithError error: Error)
}

// MARK: - SearchDataSource: NSObject

class SearchDataSource: NSObject {
    
    // MARK: Properties
    
    var photo: Photo?
    var delegate: SearchDataSourceDelegate?
    
    // MARK: Search
    
    func searchForRandomPhoto(withRequest request: FlickrRequest) {
        guard request.isValid else {
            delegate?.searchDataSource(self, didFailWithError: FlickrError.invalidSearch(description: request.invalidString))
            return
        }
        
        fetchRandomPage(withRequest: request)
    }
    
    private func fetchRandomPage(withRequest request: FlickrRequest) {
        Flickr.shared.makeRequest(request, type: PhotoResponse.self) { (parse) -> (Void) in
            if let photoResponse = parse.parsedResult as? PhotoResponse {
                let randomPage = photoResponse.photoList.randomPage()
                
                switch request {
                case .searchPhotosByLocation(let latitude, let longitude, _):
                    self.fetchRandomPhoto(withRequest: .searchPhotosByLocation(latitude: latitude, longitude: longitude, page: randomPage))
                case .searchPhotosByPhrase(let phrase, _):
                    self.fetchRandomPhoto(withRequest: .searchPhotosByPhrase(phrase, page: randomPage))
                }
            } else {
                self.delegate?.searchDataSource(self, didFailWithError: parse.error)
            }
        }
    }
    
    private func fetchRandomPhoto(withRequest request: FlickrRequest) {
        Flickr.shared.makeRequest(request, type: PhotoResponse.self) { (parse) -> (Void) in
            if let photoResponse = parse.parsedResult as? PhotoResponse {
                let randomPhoto = photoResponse.photoList.randomPhoto()
                self.photo = randomPhoto
                self.delegate?.searchDataSourceDidFetchPhoto(searchDataSource: self)
            } else {
                self.delegate?.searchDataSource(self, didFailWithError: parse.error)
            }
        }
    }
}

