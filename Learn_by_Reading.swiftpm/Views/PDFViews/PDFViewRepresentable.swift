import SwiftUI
import PDFKit
import Foundation

struct PDFViewRepresentable: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    let pdfView: CustomPDFKitView
    
    init(model: PageViewModel) {
        self.model = model
        self.pdfView = model.pdfView
        self.pdfView.pdfViewModel = model
    }
    
    var model: PageViewModel
    
    func makeUIView(context: UIViewRepresentableContext<PDFViewRepresentable>) -> PDFView {
        guard let document = PDFDocument(data: model.document.data) else {
            print("WARN: Got no pdf data to show")
            return pdfView
        }

        addTapHandler(context: context)
        pdfView.document = document
        pdfView.isUserInteractionEnabled = true
        pdfView.maxScaleFactor = 10
        pdfView.minScaleFactor = 0.5
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
    }
    
    // gesture handlers
    
    func addTapHandler(context: UIViewRepresentableContext<PDFViewRepresentable>) {
        let gesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.tapHandler))
        
        pdfView.addGestureRecognizer(gesture)
    }
    
    class Coordinator: NSObject, UIEditMenuInteractionDelegate {
        var parent: PDFViewRepresentable
        
        init(parent: PDFViewRepresentable) {
            self.parent = parent
        }
        
        @objc func tapHandler(_ sender: UITapGestureRecognizer) {
            let point = sender.location(in: parent.pdfView)
            parent.model.handleTap(point: point)
        }
    }
}

class CustomPDFKitView: PDFView {
    var pdfViewModel: PageViewModel?
    
    private func chineseSelected() -> Bool {
        return ChineseUtils.detectChinese(text: currentSelection?.string ?? "")
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return !chineseSelected() && super.canPerformAction(action, withSender: sender)
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func buildMenu(with builder: any UIMenuBuilder) {
        guard builder.system == UIMenuSystem.context else { return }
        
        if chineseSelected() {
            print("DEBUG: Build menu")
            if let model = pdfViewModel {
                print("Model!!")
                let text = currentSelection?.string?.precomposedStringWithCompatibilityMapping
                model.selection = ModelSelection(text: text ?? "", type: .freeText)
            }
            
            builder.remove(menu: .lookup)
            builder.remove(menu: .share)
            builder.remove(menu: .learn)
        } else {
            super.buildMenu(with: builder)
        }
    }
}


#Preview {
    PDFViewRepresentable(
        model: PageViewModel(document: PDFFileDocument(data: SampleData().data))
    )
}
