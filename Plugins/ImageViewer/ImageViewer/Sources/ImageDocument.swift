import AppKit
import NimbleCore

public final class ImageDocument: NSDocument, Document {

  var image: NSImage?
  
  private lazy var builderController: ImageViewerController = {
    let controller = ImageViewerController.loadFromNib()
    controller.doc = self
    return controller
  }()
  
  public var contentViewController: NSViewController? { return builderController }
  
  public static func canOpen(_ file: File) -> Bool {
    guard !file.uti.starts(with: "dy") else {
      return ["jpeg", "jpg", "png"].contains(file.path.extension.lowercased())
    }
    if file.typeIdentifierConforms(to: "public.svg-image") {
      return false
    }
    return file.typeIdentifierConforms(to: "public.image")
  }
  
  public static func isDefault(for file: File) -> Bool {
    return canOpen(file)
  }
  
   public override func read(from data: Data, ofType typeName: String) throws {
     image = NSImage(data: data)
   }
  
  public override func data(ofType typeName: String) throws -> Data {
    return "".data(using: .utf8)!
  }
}
