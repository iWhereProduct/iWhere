//
//  ServerOperations.swift
//  IWHERE
//
//  Created by Михаил on 26.01.2018.
//  Copyright © 2018 WorldCitizien. All rights reserved.
//

import Foundation
import Parse

public class ServerOperations {
    private let grandQuery: PFQuery<PFObject>
    
    init(className: String) {
        grandQuery = PFQuery(className: className)
    }
    init(){
        grandQuery = PFQuery()
    }
    /**
     Get list of coord request with specific user
     - Parameters:
        - friendId: id of that specific user
     - deniedInclude: will denied request be include?
     */
    public func getListOfCoordRequests(friendId: String, deniedInclude: Bool) -> [PFObject]?{
        grandQuery.whereKey("id", equalTo: PFUser.current()!)
        grandQuery.whereKey("friendId", equalTo: friendId)
        grandQuery.whereKey("deleted", notEqualTo: true)
        if !deniedInclude {
            grandQuery.whereKey("Accepted", equalTo: true)
        }
        grandQuery.order(byDescending: "createdAt")
        
        do {
            return try grandQuery.findObjects()
        }
        catch {
            print(error)
        }
        return nil
    }
    /**
    Get from server object, where keyword equal to some key
     - Parameters:
        - keyWord: Name of key at server
        - equalTo: For what should be equal key
        - me: don't show deleted by me/friend
     */
    
    public func getFromServer(keyWord: String, equalTo: Any, me: Bool?) -> [PFObject]?{
        grandQuery.whereKey(keyWord, equalTo: equalTo)
        grandQuery.order(byDescending: "createdAt")
        if me != nil{
            switch me!{
            case false:
                grandQuery.whereKey("friendDeleted", notEqualTo: true)
            case true:
                grandQuery.whereKey("deleted", notEqualTo: true)
            }
        }
        do{
            return try grandQuery.findObjects()
        }
        catch{
            print (error)
        }
        return nil
    }
    /**
     Save object to server
     */
    public func saveToServer(object: PFObject){
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try object.save()
            }
            catch{
                print (error)
            }
        }
    }
    /**
     Get all user information from server
     - Parameters:
        - id: user's id
     */
    public func getUserData(id: String) -> PFObject?{
        let query = PFUser.query()
        do {
            return try query!.getObjectWithId(id)
        }
        catch {
            print(error)
        }
        return nil
    }
    /**
     Get list of users, thous names contains "username"
     - Parameters:
        - username: what should contatin user's names
     */
    public func getUserList(username: String) -> [PFObject]?{
        let query = PFUser.query()
        query?.whereKey("username", contains: username)
        do {
            return try query!.findObjects()
        }
        catch {
            print(error)
        }
        return nil
    }
    /**
     Delete data from server
    */
    public func deleteAtServer(object: PFObject){
        do {
            try object.delete()
        }
        catch {
            print(error)
        }
    }
    /**
     Download data from server
     */
    public func getDataFromPFFile(PFFile: PFFile) -> Data? {
        do {
            return try PFFile.getData()
        }
        catch {
            print (error)
        }
        return nil
    }
    
    /**
     Check if there are any accepted friend requests from me. If there are some, than add them to my friendList.
     - parameters:
        - handler: The callback called after retrieval.
            - result (Bool): Returns result of checking
            - numberOfRequest (Int?): Returns ammount of accepted requsests (can be nil)
    */
    
    public func checkFriends(handler: ((_ result: Bool, _ numberOfRequest: Int?) -> Void)?) {
        if let user = PFUser.current() {
            if let friendList: [String] = user["friends"] as? [String]{
                let count = addFriendsFromRequest(user: user, actualFriendList: friendList)
                handler?(true, count)
            }
            else {
                let count = addFriendsFromRequest(user: user, actualFriendList: [])
                handler?(true, count)
            }
        }
        else {
            handler?(false, nil)
        }
    }
    
    private func addFriendsFromRequest(user: PFUser, actualFriendList: [String]) -> Int? {
        var friendList = actualFriendList
        let query = PFQuery(className: "friendsRequest")
        query.whereKey("id", equalTo: user)
        query.whereKey("Accepted", equalTo: true)
        var requsestList: [PFObject]? = nil
        do {
            requsestList = try? query.findObjects()
        }
        if requsestList != nil {
            for request in requsestList! {
                friendList.append(request["friendId"] as! String)
                deleteAtServer(object: request)
            }
            user["friends"] = friendList
            saveToServer(object: user)
            return requsestList?.count
        }
        return nil
    }
    /**
     Delete CoordRequest from server if "deleted" is true and "friendDeleted" is true, than delete object from server.
     - Parameters:
        - objectThatDeleted: CoordRequest that should be checked
        - comlitionHeandler: Calls after checking
        - result: true - objected is deleted from server, false - object will not be deleted
     */
    public func deleteIfNeeded (objectThatDeleted: PFObject, comlitionHeandler:(_ result: Bool) -> Void) {
        if let deleted = objectThatDeleted["deleted"] as? Bool, let friendDeleted = objectThatDeleted["friendDeleted"] as? Bool{
            if deleted, friendDeleted{
                deleteAtServer(object: objectThatDeleted)
                comlitionHeandler(true)
            }
            else {
                comlitionHeandler(false)
            }
        }
    }
}






