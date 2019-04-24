//
//  CollectionReference.swift
//  iChat
//
//  Created by Yi Zhang on 2019/4/24.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}


func reference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
