//
//  Snapshot.swift
//  NestoryUITests
//
//  Simple snapshot wrapper for fastlane screenshot generation
//

import Foundation
@preconcurrency import XCTest

// Device and language detection (used by fastlane)
@MainActor 
var deviceLanguage = Locale.current.languageCode ?? "en"

@MainActor
var locale = Locale.current.identifier

// Note: snapshot() and setupSnapshot() functions are provided by SnapshotHelper.swift
// This file now only contains device/language detection variables