import Foundation

enum AppError: LocalizedError {
    case dataLoadFailed
    case dataSaveFailed
    case invalidPin
    case goalLimitReached
    case rewardNotAllowed
    
    var errorDescription: String? {
        switch self {
        case .dataLoadFailed:
            return "Could not load data. Please try again."
        case .dataSaveFailed:
            return "Could not save data. Please try again."
        case .invalidPin:
            return "Invalid PIN code. Please try again."
        case .goalLimitReached:
            return "You've reached your daily goal limit."
        case .rewardNotAllowed:
            return "This reward is not allowed by your parents."
        }
    }
}

// Error handling extension
extension Result {
    var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
} 