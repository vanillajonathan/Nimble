//
//  SourceCodeDocument.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import NimbleCore


public final class SourceCodeDocument: NSDocument, Document {
  var content: String = ""
  
  private lazy var editorController: CodeEditorController = {
    let controller = CodeEditorController.loadFromNib()
    controller.doc = self
    return controller
  }()
  
  public var contentViewController: NSViewController? { return editorController }
  
  public override func read(from data: Data, ofType typeName: String) throws {
    content = String(bytes: data, encoding: .utf8)!
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return content.data(using: .utf8)!
  }
}
