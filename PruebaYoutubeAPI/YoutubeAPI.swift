//
//  YoutubeAPI.swift
//  PruebaYoutubeAPI
//
//  Created by Ernesto MB on 09/05/15.
//  Copyright (c) 2015 Ernesto MB. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func merge<K, V>(dict: [K: V]){
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}

public let YoutubeAPIKey = "AIzaSyA7yHuLOkgiXiV0Aa5zcnKIyFUjQLZOlTA"

struct YoutubeVideo : Printable {
    var videoId: String
    var title: String
    var thumbnails: NSDictionary
    var description: String {
        return "<YoutubeVideo:\(videoId)>"
    }
    init (videoId: String, title: String, thumbnails: NSDictionary) {
        self.videoId = videoId
        self.title = title
        self.thumbnails = thumbnails
    }
}

class YoutubeAPI : NSObject, Printable {
    
    private let baseHost = "www.googleapis.com"
    private let basePath = "/youtube/v3/"
    
    var apiKey: String
    var channelId: String?
    
    var maxResults: String? = "50"
    var pageToken: String?
    var nextPageToken: String?
    var previousPageToken: String?
    
    override var description: String {
        return "<YoutubeAPI:\(apiKey)>"
    }
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    init(apiKey: String, channelId: String?) {
        self.apiKey = apiKey
        self.channelId = channelId
    }
    
    func buildURLFor(resource: String, withParameters params: [String: String?]?) -> NSURL {
        var components = NSURLComponents()
        var queryString = "key=\(apiKey)"
        components.scheme = "https"
        components.host = self.baseHost
        components.path = self.basePath + resource
        var completeParams = [
            "maxResults": self.maxResults,
            "pageToken": self.pageToken,
        ]
        completeParams.merge(params!)
        
        // iOS < 8
        for (name, value) in completeParams {
            var v = value ?? ""
            queryString += "&\(name)=\(v)"
        }
        components.query = queryString
        return components.URL!
    }
    
    func getChannelPlaylists(callback: (playlists: NSDictionary?, error: NSError?) -> Void) {
        assert(self.channelId != nil, "channelId must be set")
        let params = [
            "id": self.channelId,
            "part": "snippet,contentDetails,statistics,status"
        ]
        
        let URL = self.buildURLFor("channels", withParameters: params)
        let request = NSMutableURLRequest(URL: URL)
        self.GET(request) { [unowned self](result, error) -> Void in
            if error != nil {
                callback(playlists: nil, error: error)
            } else {
                let item: AnyObject? = result?["items"]?[0]!
                let playlists = item!.valueForKeyPath("contentDetails.relatedPlaylists") as! NSDictionary
                callback(playlists: playlists, error: nil)
            }
        }
    }
    
    func handleError(error: NSError) {
        println("\n\tERROR: \(error.localizedDescription)\n")
    }
    
    func getChannelUploads(callback: (videos: [YoutubeVideo]?, error: NSError?) -> Void) {
        
        self.getChannelPlaylists({ (playlists, error) -> Void in
            if error != nil {
                callback(videos: nil, error: error)
            } else {
                var uploadsPlaylistId = playlists!["uploads"] as? String
                let params = [
                    "playlistId": uploadsPlaylistId,
                    "part": "snippet,contentDetails,status"
                ]
                let URL = self.buildURLFor("playlistItems", withParameters: params)
                let request = NSMutableURLRequest(URL: URL)
                var JSONError: NSError?
                
                self.GET(request) { (result, error) -> Void in
                    if error != nil {
                        callback(videos: nil, error: error)
                    } else {
                        let items: [NSDictionary]? = result?["items"] as? [NSDictionary]
                        // Build the YoutubeVideo objects
                        var videos = [YoutubeVideo]()
                        for i in items! {
                            let videoId = i.valueForKeyPath("contentDetails.videoId") as! String
                            let title = i.valueForKeyPath("snippet.title") as! String
                            let thumbnails = i.valueForKeyPath("snippet.thumbnails") as! NSDictionary
                            let video = YoutubeVideo(videoId: videoId, title: title, thumbnails: thumbnails)
                            videos.append(video)
                        }
                        self.previousPageToken = result?["previousPageToken"] as? String
                        self.nextPageToken = result?["nextPageToken"] as? String
                        callback(videos: videos, error: nil)
                    }
                }
            }
        })
        
    }
    
    func GET(request: NSMutableURLRequest!, callback: (NSDictionary?, NSError?) -> Void) {
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(
            configuration: configuration,
            delegate: nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        var task = session.dataTaskWithRequest(request) {
            (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if error != nil {
                self.handleError(error!)
                callback(nil, error)
            } else {
                var result = NSString(data: data, encoding: NSUTF8StringEncoding)!
                var JSONError: NSError?
                let JSON = NSJSONSerialization.JSONObjectWithData(
                    data,
                    options: nil,
                    error: &JSONError
                    ) as? NSDictionary
                
                if JSON != nil {
                    callback(JSON!, nil)
                } else {
                    callback(nil, JSONError!)
                }
            }
        }
        task.resume()
    }
}


