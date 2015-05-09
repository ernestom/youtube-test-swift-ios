//
//  MasterViewController.swift
//  PruebaYoutubeAPI
//
//  Created by Ernesto MB on 09/05/15.
//  Copyright (c) 2015 Ernesto MB. All rights reserved.
//

import UIKit


class MasterViewController: UITableViewController {
    
    var api: YoutubeAPI
    var detailViewController: DetailViewController? = nil
    var videos = [YoutubeVideo]()
    var activityView: UIActivityIndicatorView?

    func reloadData() {
        println("Loading data...")
        
        var activityContainer: UIView
        if let detailView = self.detailViewController {
            activityContainer = detailView.view
        } else {
            activityContainer = self.view
        }
        activityContainer.addSubview(self.activityView!)
        self.activityView!.startAnimating()
        
        self.api.maxResults = "5"
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
                self.tableView.reloadData()
                
                // testing
                self.tableView.selectRowAtIndexPath(
                    NSIndexPath(forRow: self.videos.count - videos!.count, inSection: 0),
                    animated: true,
                    scrollPosition: UITableViewScrollPosition.Top
                )
                self.performSegueWithIdentifier("showDetail", sender: nil)
                
            } else {
                println("Error \(error)")
            }
            self.activityView!.stopAnimating()
            //            self.activityView!.removeFromSuperview()
        }
    }

    required init!(coder aDecoder: NSCoder!) {
        self.api = YoutubeAPI(apiKey: YoutubeAPIKey, channelId: "UCn8zNIfYAQNdrFRrr8oibKw")
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        self.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nextPageButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "reloadData")
        self.navigationItem.rightBarButtonItem = nextPageButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count - 1].topViewController as? DetailViewController
        }
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let video = videos[indexPath.row] as YoutubeVideo
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = video
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let video = videos[indexPath.row] as YoutubeVideo
        let thumbnail = video.thumbnails["default"] as! NSDictionary
        let thumbnailURL = NSURL(string: thumbnail["url"] as! String)
        let image = UIImage(data: NSData(contentsOfURL: thumbnailURL!)!)
        cell.imageView?.image = image
        cell.textLabel!.text = video.title
        return cell
    }

}

