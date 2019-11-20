//
//  Dictionary + Extensions.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func setIfNotNilDic(_ key: Key, value: Value?) {
        if let value = value {
            self[key] = value
        }
    }
    
    mutating func setIfNotNil(_ key: Key, value: Any?) {
        if let value = value {
            if let bool = value as? Bool {
                setIfNotNilDic(key, value: String(bool) as? Value)
            } else {
                setIfNotNilDic(key, value: value as? Value)
            }
        }
    }
    
    public enum CastingError: Error {
        case failure(key: String)
    }
    
    func get<T>(_ key: String) throws -> T {
        guard let keyAs = key as? Key else {
            throw CastingError.failure(key: "-")
        }
        guard let obj = self[keyAs], let objAs = obj as? T else {
            throw CastingError.failure(key: key)
        }
        return objAs
    }
    
    func getOptional<T>(_ key: String) throws -> T? {
        guard let keyAs = key as? Key else {
            throw CastingError.failure(key: "-")
        }
        guard let obj = self[keyAs], !(obj is NSNull) else {
            return nil
        }
        guard let objAs = obj as? T else {
            throw CastingError.failure(key: key)
        }
        return objAs
    }
    
    
    func get<T: JsonInitializable>(_ key: String) throws -> T {
        guard let keyAs = key as? Key else {
            throw CastingError.failure(key: "-")
        }
        guard let obj = self[keyAs], let objAs = obj as? [String: AnyObject] else {
            throw CastingError.failure(key: key)
        }
        return try T(json: objAs)
    }
    
    func getOptional<T: JsonInitializable>(_ key: String) throws -> T? {
        guard let keyAs = key as? Key else {
            throw CastingError.failure(key: "-")
        }
        guard let obj = self[keyAs], !(obj is NSNull) else {
            return nil
        }
        guard let objAs = obj as? [String: AnyObject] else {
            throw CastingError.failure(key: key)
        }
        return try T(json: objAs)
    }
    
    func get<T: JsonInitializable>(_ key: String) throws -> [T] {
        guard let keyAs = key as? Key else {
            throw CastingError.failure(key: "-")
        }
        guard let obj = self[keyAs], let objAs = obj as? [[String: AnyObject]] else {
            throw CastingError.failure(key: key)
        }
        
        return try objAs.map { try T(json: $0)}
    }
    
    func getOptional<T: JsonInitializable>(_ key: String) throws -> [T]? {
        guard let keyAs = key as? Key else {
            throw CastingError.failure(key: "-")
        }
        guard let obj = self[keyAs], !(obj is NSNull) else {
            return nil
        }
        guard let objAs = obj as? [[String: AnyObject]] else {
            throw CastingError.failure(key: key)
        }
        return try objAs.map { try T(json: $0)}
    }
}
