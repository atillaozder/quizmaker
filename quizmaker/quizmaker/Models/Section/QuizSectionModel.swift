
import RxDataSources

/// :nodoc:
public enum QuizSectionModel {
    case quiz(item: Quiz)
}

/// :nodoc:
extension QuizSectionModel: SectionModelType {
    public typealias Item = Quiz
    
    public var items: [Quiz] {
        switch self {
        case .quiz(let item):
            return [item]
        }
    }
    
    public init(original: QuizSectionModel, items: [Quiz]) {
        switch original {
        case .quiz(let item):
            self = .quiz(item: item)
        }
    }
}

