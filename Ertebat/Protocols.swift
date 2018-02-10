//
//  Protocols.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/6/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation

protocol MessageReceiver:NSObjectProtocol{
    func didReceiveMessages(_ messageData: [MessageData])
}
