
import Foundation
import TipKit

struct TextAssistTip: Tip {
    var title: Text {
        Text("Enable Text Assist")
    }
    
    var message: Text? {
        Text("Receive feedback on text length to optimize your CV for ATS systems.")
    }
}
