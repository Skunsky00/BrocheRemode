//
//  UploadPostViewModel.swift
//  Broche
//
//  Created by Jacob Johnson on 5/19/23.
//

import Foundation
import PhotosUI
import SwiftUI
import Firebase

@MainActor
class UploadPostViewModel: ObservableObject {
    
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadImage(fromItem: selectedImage) } }
    }
    @Published var postImage: Image?
    private var uiImage: UIImage?
    
    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        self.postImage = Image(uiImage: uiImage)
    }
    
    func uploadPost(caption: String, location: String, label: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let uiImage = uiImage else { return }
        
        let postRef = Firestore.firestore().collection("posts").document()
        guard let imageUrl = try await ImageUploader.uploadImage(image: uiImage) else { return }
        let post = Post(id: postRef.documentID, ownerUid: uid, caption: caption, location: location, likes: 0, imageUrl: imageUrl, videoUrl: nil,  label: label, timestamp: Timestamp())
        guard let encodedPost = try? Firestore.Encoder().encode(post) else { return }
        
        try await postRef.setData(encodedPost)
    }
}


/*
@MainActor
class UploadPostViewModel: ObservableObject {
    
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadMedia(fromItem: selectedImage) } }
    }
    @Published var selectedVideo: PhotosPickerItem? {
        didSet { Task { await loadMedia(fromItem: selectedVideo) } }
    }
    @Published var postImage: Image?
    @Published var videoUrl: URL?
    private var uiImage: UIImage?
    private var videoData: Data?
    
    func loadMedia(fromItem item: PhotosPickerItem?) async {
            guard let item = item else { return }
            
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        self.uiImage = uiImage
                        self.postImage = Image(uiImage: uiImage)
                    }
                } else if let videoUrl = item.videoURL {
                    self.videoData = try await Data(contentsOf: videoUrl)
                    self.videoUrl = videoUrl
                }
            } catch {
                print("Error loading media: \(error)")
            }
        }
    
    func uploadPost(caption: String, location: String, label: String) async throws {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let postRef = Firestore.firestore().collection("posts").document()
            
            if let uiImage = uiImage {
                guard let imageUrl = try await ImageUploader.uploadImage(image: uiImage) else { return }
                let post = Post(id: postRef.documentID, ownerUid: uid, caption: caption, location: location, likes: 0, imageUrl: imageUrl, videoUrl: nil, label: label, timestamp: Timestamp())
                guard let encodedPost = try? Firestore.Encoder().encode(post) else { return }
                
                try await postRef.setData(encodedPost)
            } else if let videoData = videoData {
                guard let videoUrl = try await VideoUploader.uploadVideo(withData: videoData) else { return }
                let post = Post(id: postRef.documentID, ownerUid: uid, caption: caption, location: location, likes: 0, imageUrl: nil, videoUrl: videoUrl, label: label, timestamp: Timestamp())
                guard let encodedPost = try? Firestore.Encoder().encode(post) else { return }
                
                try await postRef.setData(encodedPost)
            }
        }
    }
*/


/*
@MainActor
class UploadPostViewModel: ObservableObject {
    
    @Published var selectedImage: PhotosPickerItem? {
didSet { Task { await loadImage(fromItem: selectedImage) } }
}
@Published var postImage: Image?
private var uiImage: UIImage?

func loadImage(fromItem item: PhotosPickerItem?) async {
guard let item = item else { return }

guard let data = try? await item.loadTransferable(type: Data.self) else { return }
guard let uiImage = UIImage(data: data) else { return }
self.uiImage = uiImage
self.postImage = Image(uiImage: uiImage)
}

func uploadPost(caption: String, location: String, label: String) async throws {
guard let uid = Auth.auth().currentUser?.uid else { return }
guard let uiImage = uiImage else { return }

let postRef = Firestore.firestore().collection("posts").document()
guard let imageUrl = try await ImageUploader.uploadImage(image: uiImage) else { return }
let post = Post(id: postRef.documentID, ownerUid: uid, caption: caption, location: location, likes: 0, imageUrl: imageUrl, label: label, timestamp: Timestamp())
guard let encodedPost = try? Firestore.Encoder().encode(post) else { return }

try await postRef.setData(encodedPost)
}
*/
