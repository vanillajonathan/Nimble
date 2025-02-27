//
//  NimbleDocument.swift
//  NimbleCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AppKit

// MARK: - Default document

open class NimbleDocument: NSDocument {
  public var observers = ObserverSet<DocumentObserver> ()

  private var filePresenter: DocumentFilePresenter? = nil

  open override var fileURL: URL? {
    get { return super.fileURL }
    set {
      let oldValue = super.fileURL
      super.fileURL = newValue
      
      if oldValue != newValue, let doc = self as? Document {

        if newValue?.scheme == .some("file") {
          if filePresenter == .none {
            filePresenter = DocumentFilePresenter(self)
          }
          filePresenter?.register()
        } else {
          filePresenter?.unregister()
        }

        observers.notify {
          $0.documentFileUrlDidChange(doc, oldFileUrl: oldValue)
        }
      }
    }
  }

  open override func writableTypes(for saveOperation: NSDocument.SaveOperationType) -> [String] {
    let types = super.writableTypes(for: saveOperation)

    return types.isEmpty ? [""] : types
  }
  
  open override func prepareSavePanel(_ savePanel: NSSavePanel) -> Bool {
    savePanel.isExtensionHidden = false
    return true
  }
  
  open override func save(to url: URL,
                          ofType typeName: String,
                          for saveOperation: NSDocument.SaveOperationType,
                          completionHandler: @escaping (Error?) -> Void) {
    
    if let doc = self as? Document {
      observers.notify{
        $0.documentWillSave(doc)
      }
      doc.editor?.workbench?.willSaveDocument(doc)
    }

    filePresenter?.unregister()

    super.save(to: url, ofType: typeName, for: saveOperation) {[weak self] in
      if $0 == nil, let doc = self as? Document {
        self?.observers.notify{
          $0.documentDidSave(doc)
        }
        doc.editor?.workbench?.didSaveDocument(doc)
      }
      completionHandler($0)
    }

    filePresenter?.register()
  }
  
  
  open override func updateChangeCount(_ change: NSDocument.ChangeType) {
    super.updateChangeCount(change)
    
    guard let doc = self as? Document else { return }
    observers.notify { $0.documentDidChange(doc) }
  }

  open func onFileDidChange() {
    guard let doc = self as? Document else { return }
    observers.notify { $0.documentFileDidChange(doc) }
  }

  deinit {
    filePresenter?.unregister()
  }
}

fileprivate class DocumentFilePresenter: NSObject, NSFilePresenter {
  
  private weak var doc: NimbleDocument?

  private var lastModificationDate: Date?
  
  public var presentedItemURL: URL? { return self.doc?.presentedItemURL }

  public var presentedItemOperationQueue: OperationQueue
  { return doc?.presentedItemOperationQueue ?? OperationQueue.main }

  private var isRegistered = false

  public init(_ doc: NimbleDocument) {
    super.init()
    self.doc = doc
  }

  public func register() {
    if !isRegistered {
      NSFileCoordinator.addFilePresenter(self)
      isRegistered = true
      lastModificationDate = documentModificationDate()
    }
  }

  public func unregister() {
    if isRegistered {
      NSFileCoordinator.removeFilePresenter(self)
      isRegistered = false
    }
  }

  func presentedItemDidChange() {
    guard isRegistered,
          let lastModificationDate = self.lastModificationDate,
          let modificationDate = documentModificationDate(),
          modificationDate > lastModificationDate else { return }

    DispatchQueue.main.async { [weak self] in
      self?.doc?.presentedItemDidChange()
      self?.lastModificationDate = modificationDate
    }
  }
  
  //Close document, when it was removed using by Finder (Move to Bin -> Empty Bin)
  func accommodatePresentedItemDeletion(completionHandler: @escaping (Error?) -> Void) {
    if isRegistered {
      DispatchQueue.main.async { [weak self] in
        guard let doc = self?.doc as? Document else { return }
        doc.editor?.workbench?.close(doc)
      }
      unregister()
    }
    completionHandler(nil)
  }

  private func documentModificationDate() -> Date? {
    guard Thread.isMainThread else {
        unregister()
        return nil
    }
    doc?.fileURL?.removeCachedResourceValue(forKey: .contentModificationDateKey)

    return try? doc?
      .fileURL?
      .resourceValues(forKeys: [.contentModificationDateKey])
      .contentModificationDate
  }
}
