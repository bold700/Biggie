import Foundation

struct ParentControl: Codable, Equatable {
    var pinCode: String
    var isEnabled: Bool
    var dailyGoalLimit: Int
    private var _allowedRewards: Set<UUID>
    var createdAt: Date
    var lastModifiedAt: Date
    var lastModifiedBy: String
    
    var allowedRewards: [UUID] {
        get { Array(_allowedRewards) }
        set { _allowedRewards = Set(newValue) }
    }
    
    var isValid: Bool {
        !pinCode.isEmpty && 
        pinCode.count == 4 && 
        pinCode.allSatisfy { $0.isNumber } &&
        dailyGoalLimit >= 1 && 
        dailyGoalLimit <= 20
    }
    
    init(
        pinCode: String = "1234",
        isEnabled: Bool = false,
        dailyGoalLimit: Int = 5,
        allowedRewards: [UUID] = [],
        createdAt: Date = Date(),
        lastModifiedAt: Date = Date(),
        lastModifiedBy: String = "system"
    ) {
        self.pinCode = pinCode
        self.isEnabled = isEnabled
        self.dailyGoalLimit = dailyGoalLimit
        self._allowedRewards = Set(allowedRewards)
        self.createdAt = createdAt
        self.lastModifiedAt = lastModifiedAt
        self.lastModifiedBy = lastModifiedBy
    }
    
    static let `default` = ParentControl()
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case pinCode, isEnabled, dailyGoalLimit
        case _allowedRewards = "allowedRewards"
        case createdAt, lastModifiedAt, lastModifiedBy
    }
    
    // MARK: - Equatable
    static func == (lhs: ParentControl, rhs: ParentControl) -> Bool {
        lhs.pinCode == rhs.pinCode &&
        lhs.isEnabled == rhs.isEnabled &&
        lhs.dailyGoalLimit == rhs.dailyGoalLimit &&
        lhs._allowedRewards == rhs._allowedRewards &&
        lhs.createdAt == rhs.createdAt &&
        lhs.lastModifiedAt == rhs.lastModifiedAt &&
        lhs.lastModifiedBy == rhs.lastModifiedBy
    }
} 