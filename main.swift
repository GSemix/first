import SwiftUI

struct mainContent: Hashable {
    var image: UIImage = UIImage()
    var test: String = String()
}

struct Page: View {
    @Binding var main: Dictionary<Int, mainContent>
    @State var blurMap: Bool = false
    @State var image: UIImage = UIImage()
    @State var zIndexValue: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                Spacer()
                    .frame(height: UIScreen.main.bounds.height*0.08)
                
                ForEach (Array(main.keys).sorted(by: {$0 < $1}), id: \.self) { m in
                    Picture(image: main[m]!.image, text: main[m]!.text)
                        .onTapGesture(count: 1) {
                            zIndexValue = true
                            image = main[m]!.image
                            blurMap = true
                    }
                }
            }
                .disabled(zIndexValue)
                .blur(radius: blurMap ? 15 : 0)
                .zIndex(zIndexValue ? 0 : 1)
            
            // MARK: - This picture i want to pinch zoom
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: UIScreen.main.bounds.height*0.25)
                .zIndex(zIndexValue ? 1 : 0)
            // MARK: - I did this, but OFFSET and SCALE are remembered when I open another picture
            
//            Zoom {
//                Image(uiImage: image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(height: UIScreen.main.bounds.height*0.25)
//            }
//                .zIndex(zIndexValue ? 1 : 0)
            
        }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
            .onTapGesture(count: 1) {
                zIndexValue = false
                image = UIImage()
                blurMap = false
            }
    }
}

struct Zoom<Content: View>: UIViewRepresentable {
  private var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
  }

    func makeUIView(context: Context) -> UIScrollView {

    let scrollView = UIScrollView()
    scrollView.delegate = context.coordinator
    scrollView.maximumZoomScale = 4
    scrollView.minimumZoomScale = 1
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.bouncesZoom = true

    let hostedView = context.coordinator.hostingController.view!
    hostedView.translatesAutoresizingMaskIntoConstraints = true
    hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostedView.frame = scrollView.bounds
    hostedView.backgroundColor = UIColor.clear
    scrollView.addSubview(hostedView)

    return scrollView
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(hostingController: UIHostingController(rootView: self.content))
  }

  func updateUIView(_ uiView: UIScrollView, context: Context) {
    context.coordinator.hostingController.rootView = self.content
    assert(context.coordinator.hostingController.view.superview == uiView)
  }

  class Coordinator: NSObject, UIScrollViewDelegate {
    var hostingController: UIHostingController<Content>

    init(hostingController: UIHostingController<Content>) {
      self.hostingController = hostingController
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return hostingController.view
    }
  }
}

struct Picture: View {
    var image: UIImage
    var text: String
    
    var body: some View {
        VStack {
            ZoomableScrollView {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: UIScreen.main.bounds.height*0.25)
            }
            .frame(height: UIScreen.main.bounds.height*0.3)
            
            HStack {
                Firefly()
                
                Text(text)
                    .foregroundColor(Color.white)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.35, alignment: .center)
        .padding(.vertical, 5)
    }
}

struct Firefly: View {
    var body: some View {
        Circle()
            .fill(Color.blue)
            .shadow(color: Color.white, radius: 2.5)
            .frame(width: 5, height: 5)
    }
}
