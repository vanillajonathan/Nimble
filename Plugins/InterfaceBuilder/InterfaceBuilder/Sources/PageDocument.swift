import AppKit
import NimbleCore
import ScadeKit
import SVGEditor

public final class PageDocument: NimbleDocument, SVGDocumentProtocol {
  
  let adapter = SCDLatticeEditorPageAdapter()

  public var svgWidth: SCDSvgUnit? {
    guard let width = page?.size.width else { return nil }

    return SCDSvgUnit(value: Float(width))
  }
  
  public var svgHeight: SCDSvgUnit? {
    guard let height = page?.size.height else { return nil }

    return SCDSvgUnit(value: Float(height))
  }

  public var rootSvg: SCDSvgBox? {
    return page?.drawing as? SCDSvgBox
  }

  public var page: SCDWidgetsPage? {
    return adapter.page
  }

  private lazy var builderController: EditorView = {
    let controller = EditorView.loadFromNib()
    controller.document = self

    return controller
  }()

  override public func presentedItemDidChange() {
    guard let url = self.fileURL, let type = self.fileType  else { return }

    DispatchQueue.main.async { [weak self] in
      try! self?.read(from: url, ofType: type)
      self?.onFileDidChange()
    }
  }
  
  public override func read(from url: URL, ofType typeName: String) throws {
    adapter.load(url.path)
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return "".data(using: .utf8)!
  }
}

extension PageDocument: Document {
  public var editor: WorkbenchEditor? { builderController }
  
  /// TODO: register UTIs for the page files
  public static var typeIdentifiers: [String] = []
  
  public static func canOpen(_ file: File) -> Bool {
    return file.path.extension == "page"
  }
  
  public static func isDefault(for file: File) -> Bool {
    return canOpen(file)
  }
}
