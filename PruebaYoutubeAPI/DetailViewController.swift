//
//  DetailViewController.swift
//  PruebaYoutubeAPI
//
//  Created by Ernesto MB on 09/05/15.
//  Copyright (c) 2015 Ernesto MB. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var videoContainerView: YTPlayerView!

    var detailItem: YoutubeVideo? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        if let video: YoutubeVideo = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = video.title
            }
            if let view = self.videoContainerView {
                view.loadWithVideoId(video.videoId, playerVars: [
                    "autoplay": "1",
                    "playsinline": "1",
                    "fs": "1"
                ])
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

