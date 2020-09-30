//
//  Automatic.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 21/02/2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Foundation
import NimbleCore

public class Automatic: BuildSystem {
  public static let shared = Automatic()
  
  private init() {}
  
  public var name: String {
    return "Automatic"
  }
  
  public func targetsBySystem(in workbench: Workbench) -> [[Target]] {
    let systems = BuildSystemsManager.shared.buildSystems
    return systems.sorted{$0.name.lowercased() < $1.name.lowercased()}.map{$0.targets(in: workbench)}
  }
  
  public func targets(in workbench: Workbench) -> [Target] {
    let systems = BuildSystemsManager.shared.buildSystems
    return systems.sorted{$0.name.lowercased() < $1.name.lowercased()}.flatMap{$0.targets(in: workbench)}
  }
  
  public func run(_ variant: Variant) {
    variant.buildSystem?.run(variant)
  }
  
  public func build(_ variant: Variant) {
     variant.buildSystem?.build(variant)
  }
  
  public func clean(_ variant: Variant) {
    variant.buildSystem?.clean(variant)
  }
}

