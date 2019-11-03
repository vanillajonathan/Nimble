//
//  Workbench.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

public protocol Workbench {
  var project: Project? { get }
  
  var navigatorArea: WorkbenchArea? { get }
  
  var changedFiles: [File]? { get }

//  var inspectorArea: WorkbenchPart { get }
//
//  var toolbarArea: WorkbenchPart { get }
//
  
  var debugArea: WorkbenchArea? { get }
  
  
  
  @discardableResult
  func open(file: File) -> Document?
  
  func preview(file: File)
  
  func save(file: File)
  
  func createConsole(title: String, show: Bool) -> Console?
}

public protocol WorkbenchArea {
  func add(part: WorkbenchPart) -> Void
}

public protocol Hideable {
  var isHidden: Bool { get set }
}


public protocol WorkbenchPart {
  var view: NSView { get }
  
  var title: String? { get }
  
  var icon: NSImage? { get }
}
