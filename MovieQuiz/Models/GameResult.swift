import Foundation
import UIKit

struct GameResult: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    // метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        if correct > another.correct {
            return true
        } else if correct == another.correct {
            return date > another.date // сравнение по дате, если счетчик одинаковый
        }
        return false
    }
}
