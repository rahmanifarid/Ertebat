//
//  AllDataModels.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/9/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation

enum PostType{
    case text
    case picture
    case video
}

struct Post {
    var type:PostType?
    var pictureUrl: String?
    var videoUrl: String?
    var text:String?
    var authorId:String?
    var date:NSDate?
    init(type:PostType? = PostType.text, date:NSDate?, authorId:String?, text:String?, pictureUrl:String?, videoUrl:String?) {
        self.type = type
        self.date = date
        self.authorId = authorId
        self.text = text
        self.pictureUrl = pictureUrl
        self.videoUrl = videoUrl
    }
    
    static func createWith(data:[String: Any]) -> Post{
        let post = Post(type: data["type"] as? PostType, date: data["date"] as? NSDate, authorId: data["authorId"] as? String, text: data["text"] as? String, pictureUrl: data["pictureUrl"] as? String, videoUrl: data["videoUrl"] as? String)
        return post
    }
}

struct User{
    var name: String?
    var profileUrl: String?
    var id: String?
    
    static func createWith(data:[String : Any]) -> User{
        return User(name: data["name"] as? String, profileUrl: data["profileURL"] as? String, id: data["id"] as? String)
    }
    
}

enum MessageType: Int{
    case text
    case picture
}
struct Message:Comparable{
    static func <(lhs: Message, rhs: Message) -> Bool {
        if let left = lhs.date, let right = rhs.date{
            return left < right
        }
        return false
    }
    
    static func ==(lhs: Message, rhs: Message) -> Bool {
        if let left = lhs.date, let right = rhs.date{
            return left == right
        }
        return false
    }
    
    var type:String?
    var senderId:String?
    var receiverId:String?
    var text:String?
    var pictureUrl:String?
    var date:Date?
    
    func data() -> [String:Any] {
        return ["type": type ?? "", "senderId": senderId ?? "", "receiverId": receiverId ?? "", "text": text ?? "", "pictureUrl": pictureUrl ?? "", "date": date ?? ""]
    }
    
    static func initWithData(_ data:[String: Any])-> Message{
        return Message(type: data["type"] as? String, senderId: data["senderId"] as? String, receiverId: data["receiverId"] as? String, text: data["text"] as? String, pictureUrl: data["pictureUrl"] as? String, date: data["date"] as? Date)
    }
    
    
}
