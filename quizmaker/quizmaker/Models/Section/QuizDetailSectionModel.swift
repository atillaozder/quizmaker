
import Foundation
import UIKit
import RxDataSources

public enum QuizDetailSectionModel {
    case detail(item: Quiz)
    case participants(item: [QuizParticipant])
    case questions(item: [Question])
    
    var count: Int {
        switch self {
        case .detail:
            return 0
        case .participants(let item):
            return item.count
        case .questions(let item):
            return item.count
        }
    }
}

public enum DetailSectionModel {
    case detail(item: QuizDetailSectionModel)
    case participants(item: QuizDetailSectionModel)
    case questions(item: QuizDetailSectionModel)
}

extension DetailSectionModel: SectionModelType {
    public typealias Item = QuizDetailSectionModel
    
    public var items: [QuizDetailSectionModel] {
        switch self {
        case .detail(let item):
            return [item]
        case .participants(let item):
            return [item]
        case .questions(let item):
            return [item]
        }
    }
    
    var title: String {
        switch self {
        case .detail:
            return "Quiz Informations"
        case .participants(let item):
            return "Participants(\(item.count))"
        case .questions(let item):
            return "Questions(\(item.count))"
        }
    }
    
    var image: UIImage {
        switch self {
        case .detail:
            return UIImage(imageLiteralResourceName: "quiz")
        case .participants:
            return UIImage(imageLiteralResourceName: "profile")
        case .questions:
            return UIImage(imageLiteralResourceName: "question")
        }
    }
    
    public init(original: DetailSectionModel, items: [QuizDetailSectionModel]) {
        switch original {
        case .detail(let item):
            self = .detail(item: item)
        case .participants(let item):
            self = .participants(item: item)
        case .questions(let item):
            self = .questions(item: item)
        }
    }
}
