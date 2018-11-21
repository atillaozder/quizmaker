import RxDataSources

enum QuizSectionModel {
    case quiz(item: [Quiz])
}

extension QuizSectionModel: SectionModelType {
    typealias Item = [Quiz]
    
    var items: [[Quiz]] {
        switch self {
        case .quiz(let item):
            return [item]
        }
    }
    
    init(original: QuizSectionModel, items: [[Quiz]]) {
        switch original {
        case .quiz(let item):
            self = .quiz(item: item)
        }
    }
}