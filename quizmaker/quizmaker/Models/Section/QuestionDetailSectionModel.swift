
import Foundation
import RxDataSources

/// :nodoc:
public enum QuestionSectionModel {
    case multichoice(item: Question)
    case text(item: Question)
    case truefalse(item: Question)
}

/// :nodoc:
public enum QuestionDetailSectionModel {
    case multichoice(item: QuestionSectionModel)
    case text(item: QuestionSectionModel)
    case truefalse(item: QuestionSectionModel)
}

/// :nodoc:
extension QuestionDetailSectionModel: SectionModelType {
    public typealias Item = QuestionSectionModel
    
    public var items: [QuestionSectionModel] {
        switch self {
        case .multichoice(let item):
            return [item]
        case .text(let item):
            return [item]
        case .truefalse(let item):
            return [item]
        }
    }
    
    public init(original: QuestionDetailSectionModel, items: [QuestionSectionModel]) {
        switch original {
        case .multichoice(let item):
            self = .multichoice(item: item)
        case .text(let item):
            self = .text(item: item)
        case .truefalse(let item):
            self = .truefalse(item: item)
        }
    }
}

