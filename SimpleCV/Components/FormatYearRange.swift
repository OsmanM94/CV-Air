

import Foundation

func formatYearRange(start: Int, end: Int?) -> String {
    if let end = end {
        return "\(start) - \(end)"
    } else {
        return "\(start) - Present"
    }
}
