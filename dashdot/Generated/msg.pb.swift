// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: msg.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct Msg_NewMsg {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var text: String = String()

  public var userID: Int32 = 0

  public var chatID: Int32 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Msg_MsgSent {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: Int32 = 0

  public var date: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _date ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_date = newValue}
  }
  /// Returns true if `date` has been explicitly set.
  public var hasDate: Bool {return self._date != nil}
  /// Clears the value of `date`. Subsequent reads from it will return its default value.
  public mutating func clearDate() {self._date = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _date: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
}

public struct Msg_Msg {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: Int32 = 0

  public var date: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _date ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_date = newValue}
  }
  /// Returns true if `date` has been explicitly set.
  public var hasDate: Bool {return self._date != nil}
  /// Clears the value of `date`. Subsequent reads from it will return its default value.
  public mutating func clearDate() {self._date = nil}

  public var text: String = String()

  public var userID: Int32 = 0

  public var chatID: Int32 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _date: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Msg_NewMsg: @unchecked Sendable {}
extension Msg_MsgSent: @unchecked Sendable {}
extension Msg_Msg: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "msg"

extension Msg_NewMsg: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".NewMsg"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "text"),
    2: .standard(proto: "user_id"),
    3: .standard(proto: "chat_id"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.text) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.userID) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.chatID) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.text.isEmpty {
      try visitor.visitSingularStringField(value: self.text, fieldNumber: 1)
    }
    if self.userID != 0 {
      try visitor.visitSingularInt32Field(value: self.userID, fieldNumber: 2)
    }
    if self.chatID != 0 {
      try visitor.visitSingularInt32Field(value: self.chatID, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Msg_NewMsg, rhs: Msg_NewMsg) -> Bool {
    if lhs.text != rhs.text {return false}
    if lhs.userID != rhs.userID {return false}
    if lhs.chatID != rhs.chatID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Msg_MsgSent: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".MsgSent"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "date"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.id) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._date) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.id != 0 {
      try visitor.visitSingularInt32Field(value: self.id, fieldNumber: 1)
    }
    try { if let v = self._date {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Msg_MsgSent, rhs: Msg_MsgSent) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs._date != rhs._date {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Msg_Msg: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Msg"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "date"),
    3: .same(proto: "text"),
    4: .standard(proto: "user_id"),
    5: .standard(proto: "chat_id"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.id) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._date) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.text) }()
      case 4: try { try decoder.decodeSingularInt32Field(value: &self.userID) }()
      case 5: try { try decoder.decodeSingularInt32Field(value: &self.chatID) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.id != 0 {
      try visitor.visitSingularInt32Field(value: self.id, fieldNumber: 1)
    }
    try { if let v = self._date {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if !self.text.isEmpty {
      try visitor.visitSingularStringField(value: self.text, fieldNumber: 3)
    }
    if self.userID != 0 {
      try visitor.visitSingularInt32Field(value: self.userID, fieldNumber: 4)
    }
    if self.chatID != 0 {
      try visitor.visitSingularInt32Field(value: self.chatID, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Msg_Msg, rhs: Msg_Msg) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs._date != rhs._date {return false}
    if lhs.text != rhs.text {return false}
    if lhs.userID != rhs.userID {return false}
    if lhs.chatID != rhs.chatID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
