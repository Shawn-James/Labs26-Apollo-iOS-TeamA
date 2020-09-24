//
//  FetchController.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/22/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation
import CoreData

class FetchController {
    // MARK: - Properties -
    let profileController = ProfileController.shared

    // MARK: - Fetch Requests -

    /// Fetches [Topic] from CoreData based on predicate
    /// - Parameters:
    ///   - predicate: NSPredicate used to filter CoreData results
    ///   - context: The context used to execute the request (no default)
    /// - Returns: An array of Topic if the fetch succeeds, nil if it fails
    private func fetchTopicRequest(with predicate: NSPredicate, context: NSManagedObjectContext) -> [Topic]? {

        let fetchRequest: NSFetchRequest<Topic> = Topic.fetchRequest()

        fetchRequest.predicate = predicate
        do {
            let topics = try context.fetch(fetchRequest)
            return topics
        } catch let fetchError {
            print("Error Fetching Topics user is a Leader of: \(fetchError)")
            return nil
        }

    }

    /// Fetches [Topic] from CoreData where the currently logged in user matches the Topic's leaderId
    /// - Parameters:
    ///   - identifiersToFetch: The identifiers of Topics to attempt to retrieve from CoreData
    ///   - context: The context used to execute the request
    /// - Returns: An array of Topic on success, or nil on failure
    func fetchLeaderTopics(with identifiersToFetch: [Int], context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> [Topic]? {
        guard let userID = profileController.authenticatedUserProfile?.id else {
            print("user not logged in, testing")
            let userID = "Test1"
            let predicate = NSPredicate(format: "id IN %@ AND leaderId == %@", identifiersToFetch, userID)
            return fetchTopicRequest(with: predicate, context: context)
        }
        let predicate = NSPredicate(format: "id IN %@ AND leaderId == %@", identifiersToFetch, userID)

        return fetchTopicRequest(with: predicate, context: context)
    }

    /// Fetches [Topic] from CoreData where the currently logged in user matches a member in the Topic
    /// - Parameters:
    ///   - identifiersToFetch: The identifiers of Topics to attempt to retrieve from CoreData
    ///   - context: The context used to execute the request
    /// - Returns: An array of Topic on success, or nil on failure
    func fetchMemberTopics(with identifiersToFetch: [Int], context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> [Topic]? {

        guard let user = profileController.authenticatedUserProfile else {
            print("user not logged in")
            return nil
        }

        // need predicate for id IN identifiersToFetch AND userId IN Topic.members.map { $0.id }
        // (member in Topic.members)
        let predicate = NSPredicate(format: "id IN %@ AND %@ IN members", identifiersToFetch, user)

        return fetchTopicRequest(with: predicate, context: context)
    }
}