//
//  FirestoreModel.swift
//  FirestorePractice
//
//  Created by 肥沼英里 on 2021/04/23.
//

import Foundation
import FirebaseFirestore

final class FirestoreModel{
    
    static func save(inputWord: String){
        Firestore.firestore().collection("InputWord").addDocument(data: [
            "uid": FirebaseAuthModel.uid,
            "createdAt": FieldValue.serverTimestamp(),
            "keyWord": inputWord
        ]) { (error) in
            if let error = error{
                print("Error adding document：\(error)")
            }else{
                print("Successfully document added")
            }
        }
    }
    
    static func getWords(completion: @escaping(Result<InputWordsData, Error>)->Void){
        let inputWordRef = Firestore.firestore().collection("InputWord").whereField("uid", in: ["\(FirebaseAuthModel.uid)"])
        //入力日時順に最新30件を取得する
        let inputWord = inputWordRef.order(by: "createdAt", descending: true).limit(to: 30)
        inputWord.addSnapshotListener { (querySnapshot, error) in
            if let error = error{
                completion(.failure(error))
            } else {
                guard let querySnapshot = querySnapshot else { return }
                var keyWordArray = [String]()
                var idArray = [String]()
                for document in querySnapshot.documents{
                    guard let keyWord = document.data()["keyWord"] as? String else { return }
                    keyWordArray.append(keyWord)
                    idArray.append(document.documentID)
                }
                let data = InputWordsData(keyWords: keyWordArray, documentID: idArray)
                completion(.success(data))
            }
        }
    }
    
    static func delete(documentID: String){
        Firestore.firestore().collection("InputWord").document(documentID).delete { (error) in
            if let error = error{
                print("Error deleting document:\(error)")
            }else{
                print("Successfully document deleted")
            }
        }
    }
    
    static func overwrite(documentID: String){
        Firestore.firestore().collection("InputWord").document(documentID).setData([
            "createdAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}

struct InputWordsData{
    var keyWords: [String]
    var documentID: [String]
}
