//
//  NotificationsViewModel.swift
//  Broche
//
//  Created by Jacob Johnson on 6/19/23.
//

import SwiftUI
import Firebase

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications = [Notification]()
    
    init() {
        Task { try await updateNotifications() }
    }
    
    private func fetchNotifications() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let query = COLLECTION_NOTIFICATIONS
            .document(uid).collection("user-notifications")
            .order(by: "timestamp", descending: true)

        guard let snapshot = try? await query.getDocuments() else { return }
        self.notifications = snapshot.documents.compactMap({ try? $0.data(as: Notification.self) })
    }
    
    func updateNotifications() async throws {
        await fetchNotifications()
        
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for notification in notifications {
                group.addTask { try await self.updateNotificationMetadata(notification: notification) }
            }
        })
    }
    
    static func deleteNotification(toUid uid: String, type: NotificationType, postId: String? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications")
            .whereField("uid", isEqualTo: currentUid).getDocuments { snapshot, _ in
                snapshot?.documents.forEach({ document in
                    let notification = try? document.data(as: Notification.self)
                    guard notification?.type == type else { return }
                    
                    if postId != nil {
                        guard postId == notification?.postId else { return }
                    }
                    
                    document.reference.delete()
                })
            }
    }
    
    static func uploadNotification(toUid uid: String, type: NotificationType, post: Post? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }
        
        var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                   "uid": currentUid,
                                   "type": type.rawValue]
        
        if let post = post, let id = post.id {
            data["postId"] = id
        }
        
        COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").addDocument(data: data)
    }
    
    private func updateNotificationMetadata(notification: Notification) async throws {
        guard let indexOfNotification = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        
        async let notificationUser = try await UserService.fetchUser(withUid: notification.uid)
        self.notifications[indexOfNotification].user = try await notificationUser

        if notification.type == .follow {
            async let isFollowed = await UserService.checkIfUserIsFollowed(uid: notification.uid)
            self.notifications[indexOfNotification].isFollowed = await isFollowed
        }

        if let postId = notification.postId {
            async let postSnapshot = await COLLECTION_POSTS.document(postId).getDocument()
            self.notifications[indexOfNotification].post = try? await postSnapshot.data(as: Post.self)
        }
    }
}
