//
//  TabBarController.swift
//  IWHERE
//
//  Created by Михаил on 29.03.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery

class TabBarController: UITabBarController {
    
    let liveQueryClient: Client = ParseLiveQuery.Client(server: "wss://iwhere.back4app.io", applicationId: "9Eabi9MtguYHgApu6epzC4Jjm7epD8KOlvazrLwq", clientKey: "ftNlyX1D88TqyDNBkOo5iihwL9inz54nstnm3XZr")
    private var subscriptionForCoords: Subscription<PFObject>!
    private var subscriptionForFriends: Subscription<PFObject>!

    var friendItem: UITabBarItem!
    var historyItem: UITabBarItem!
    var friendVC: FriendVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        friendItem = tabBar.items![0]
        historyItem = tabBar.items![2]
    
        let msgQueryForCoords = PFQuery(className: "coordRequest").whereKey("friendId", equalTo: PFUser.current()!.objectId!)
        subscriptionForCoords = liveQueryClient.subscribe(msgQueryForCoords).handle(Event.created) { [weak self ]query, message in
            if let previosNumber = self?.historyItem.badgeValue{
                DispatchQueue.main.async {
                    self?.historyItem.badgeValue = String(Int(previosNumber)! + 1)
                }
            }
            else {
                DispatchQueue.main.async {
                    self?.historyItem.badgeValue = "1"
                }
            }
        }
        
        let msgQueryForFriends = PFQuery(className: "friendsRequest").whereKey("friend", equalTo: PFUser.current()!)
        subscriptionForFriends = liveQueryClient.subscribe(msgQueryForFriends).handle(Event.created){ [weak self](query, message) in
            if let previosNumber = self?.friendItem.badgeValue{
                DispatchQueue.main.async {
                    self?.friendItem.badgeValue = String(Int(previosNumber)! + 1)
                    self?.friendVC?.setUpBadge(string: String(Int(previosNumber)! + 1))
                }
            }
            else {
                DispatchQueue.main.async {
                    self?.friendItem.badgeValue = "1"
                    self?.friendVC?.bageImage.isHidden = false
                    self?.friendVC?.setUpBadge(string: "1")
                }
            }
        }
    }
}
