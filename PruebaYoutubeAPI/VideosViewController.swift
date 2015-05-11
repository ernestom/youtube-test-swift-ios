//
//  VideosViewController.swift
//  PruebaYoutubeAPI
//
//  Created by Ernesto MB on 11/05/15.
//  Copyright (c) 2015 Ernesto MB. All rights reserved.
//


class VideosViewController: UICollectionViewController {
    
    var api: YoutubeAPI
    var detailViewController: DetailViewController? = nil
    var videos = [YoutubeVideo]()
    var activityView: UIActivityIndicatorView?
    
    func reloadData() {
        println("Loading data...")
        

        self.activityView!.startAnimating()
        
        self.api.maxResults = "50"
        // Youtube API Responses return nextPageToken and previousPageToken,
        // that we can use to set the pageToken parameter to paginate results.
        // By automatically adding the nextPageToken (which is nil in the first load)
        // to the pageToken, we just need to invoke this method again to load the next page
        self.api.pageToken = self.api.nextPageToken
        self.api.getChannelUploads() { (videos, error) -> Void in
            if videos != nil {
                self.videos += videos!
                println("Videos: \(videos!)")
                println("Prev page token: \(self.api.previousPageToken)")
                println("Next page token: \(self.api.nextPageToken)")
                self.collectionView?.reloadData()
            } else {
                println("Error \(error)")
            }
            self.activityView!.stopAnimating()
        }
    }
    
    
    required init(coder aDecoder: NSCoder) {
        self.api = YoutubeAPI(apiKey: YoutubeAPIKey, channelId: "UCn8zNIfYAQNdrFRrr8oibKw")
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.activityView == nil {
            self.activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            self.activityView!.frame = CGRectMake(0, 0, screenSize.size.width, screenSize.size.height)
            self.activityView!.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0) //self.tableView.center
            self.activityView!.backgroundColor = UIColor.darkGrayColor()
            self.activityView!.hidesWhenStopped = true
            self.activityView!.autoresizingMask = (
                UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleWidth |
                    UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin |
                    UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleBottomMargin
            );
        }
        self.view.addSubview(self.activityView!)
        self.reloadData()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("VideoCell", forIndexPath: indexPath) as! UICollectionViewCell
    
        cell.backgroundColor = UIColor.cyanColor()

        let video = videos[indexPath.row] as YoutubeVideo
        let thumbnail = video.thumbnails["high"] as! NSDictionary
        let thumbnailURL = NSURL(string: thumbnail["url"] as! String)
        let image = UIImage(data: NSData(contentsOfURL: thumbnailURL!)!)

        let player = cell.viewWithTag(1000) as! YTPlayerView
        
        player.loadWithVideoId(video.videoId, playerVars: [
            "autoplay": "1",
            "playsinline": "0",
            "fs": "1"
        ])
        
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videos.count;
    }
}
