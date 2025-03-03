import Foundation
import UIKit

// Расширяем при объявлении
final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys {
        static let correctAnswers = "correctAnswers"
        static let totalQuestions = "totalQuestions"
        static let gamesCount = "gamesCount"
        static let bestGame = "bestGame"
    }
    
    var totalAccuracy: Double {
        let correct = storage.integer(forKey: Keys.correctAnswers)
        let total = storage.integer(forKey: Keys.totalQuestions)
        return total == 0 ? 0 : (Double(correct) / Double(total)) * 100
    }
    
    var gamesCount: Int {
        get {
            // Добавьте чтение значения из UserDefaults
            storage.integer(forKey: Keys.gamesCount)
        }
        set {
            // Добавьте запись значения newValue в UserDefaults
            storage.set(newValue, forKey: Keys.gamesCount)
        }
    }
    
    var bestGame: GameResult {
        get {
            guard let data = storage.data(forKey: Keys.bestGame),
                  let bestGame = try? JSONDecoder().decode(GameResult.self, from: data) else {
                return GameResult(correct: 0, total: 0, date: Date())
            }
            return bestGame
        }
        set {
            
            guard newValue.isBetterThan(bestGame),
                  let encoded = try? JSONEncoder().encode(newValue) else { return }
            storage.set(encoded, forKey: Keys.bestGame)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let newGame = GameResult(correct: count, total: amount, date: Date())
        
        gamesCount += 1
        storage.set(storage.integer(forKey: Keys.correctAnswers) + count, forKey: Keys.correctAnswers)
        storage.set(storage.integer(forKey: Keys.totalQuestions) + amount, forKey: Keys.totalQuestions)
        
        bestGame = newGame
    }
}
