import SwiftUI
import WebKit
import SceneKit

struct Sel: Identifiable { let id: Int }

final class Coord: NSObject, WKScriptMessageHandler {
    let onShow: (Int) -> Void
    init(_ f: @escaping (Int) -> Void) { onShow = f }
    func userContentController(_ c: WKUserContentController, didReceive m: WKScriptMessage) {
        if let k = m.body as? Int { DispatchQueue.main.async { self.onShow(k) } }
    }
}

struct WebView: UIViewRepresentable {
    let onShow: (Int) -> Void
    func makeCoordinator() -> Coord { Coord(onShow) }
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "v3d")
        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = .clear
        web.scrollView.bounces = false
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return web
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct ContentView: View {
    @State private var sel: Sel?
    var body: some View {
        WebView { k in sel = Sel(id: k) }
            .ignoresSafeArea()
            .sheet(item: $sel) { s in ModelSheet(k: s.id) }
    }
}

struct ModelSheet: View {
    let k: Int
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(partNames[k]).font(.headline)
                Spacer()
                Button("Fechar") { dismiss() }
            }.padding([.horizontal, .top])
            SceneView(scene: makeScene(k), options: [.allowsCameraControl, .autoenablesDefaultLighting])
            Text("Arraste para girar, pince para dar zoom.").font(.footnote).foregroundColor(.secondary).padding(.bottom)
        }
    }
}
