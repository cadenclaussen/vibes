//
//  AchievementNotificationService.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import SwiftUI
import Combine

@MainActor
class AchievementNotificationService: ObservableObject {
    static let shared = AchievementNotificationService()

    @Published var currentBanner: Achievement?
    @Published var isShowingBanner = false

    private var bannerQueue: [Achievement] = []
    private var isProcessingQueue = false
    private var currentUserId: String?

    private init() {}

    // Set current user ID (call on sign-in)
    func setCurrentUser(_ userId: String?) {
        currentUserId = userId
    }

    // User-specific key for storing seen achievements
    private var unlockedKey: String {
        guard let userId = currentUserId else { return "unlocked_achievements" }
        return "unlocked_achievements_\(userId)"
    }

    // Get previously unlocked achievement IDs from UserDefaults
    private var previouslyUnlockedIds: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: unlockedKey) ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: unlockedKey)
        }
    }

    // Sync achievements on first sign-in (populate without showing notifications)
    func syncAchievementsOnSignIn(_ achievements: [Achievement]) {
        guard currentUserId != nil else { return }
        let currentlyUnlocked = Set(achievements.filter { $0.isUnlocked }.map { $0.id })
        // Just update the stored list without showing banners
        previouslyUnlockedIds = currentlyUnlocked
    }

    // Check for newly unlocked achievements and show banners
    func checkForNewAchievements(_ achievements: [Achievement]) {
        guard currentUserId != nil else { return }

        let currentlyUnlocked = Set(achievements.filter { $0.isUnlocked }.map { $0.id })

        // Check if this is first time for this user (key doesn't exist)
        let isFirstTime = UserDefaults.standard.stringArray(forKey: unlockedKey) == nil

        if isFirstTime {
            // First time for this user - just sync without notifications
            previouslyUnlockedIds = currentlyUnlocked
            return
        }

        let previouslyUnlocked = previouslyUnlockedIds

        // Find newly unlocked achievements
        let newlyUnlocked = currentlyUnlocked.subtracting(previouslyUnlocked)

        if !newlyUnlocked.isEmpty {
            // Add new achievements to queue
            for achievementId in newlyUnlocked {
                if let achievement = achievements.first(where: { $0.id == achievementId }) {
                    bannerQueue.append(achievement)
                }
            }

            // Store current unlocked set (not union - allows re-earning after data reset)
            previouslyUnlockedIds = currentlyUnlocked

            // Start processing queue if not already
            processQueue()
        } else {
            // Store current unlocked set
            previouslyUnlockedIds = currentlyUnlocked
        }
    }

    private func processQueue() {
        guard !isProcessingQueue, !bannerQueue.isEmpty else { return }

        isProcessingQueue = true
        let achievement = bannerQueue.removeFirst()

        // Play haptic
        HapticService.success()

        // Show banner
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentBanner = achievement
            isShowingBanner = true
        }

        // Hide after delay
        Task {
            try? await Task.sleep(nanoseconds: 3_500_000_000) // 3.5 seconds

            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isShowingBanner = false
            }

            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds for animation
            currentBanner = nil
            isProcessingQueue = false

            // Process next in queue
            processQueue()
        }
    }

    // Reset unlocked achievements (for testing)
    func resetUnlockedAchievements() {
        previouslyUnlockedIds = []
    }

    // Clear all data for current user (call on account deletion)
    func clearUserData() {
        previouslyUnlockedIds = []
        bannerQueue.removeAll()
        currentBanner = nil
        isShowingBanner = false
        currentUserId = nil
    }
}
