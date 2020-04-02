//
//  NetworkUtility.swift
//  Wiggle
//
//  Created by Murat Turan on 2.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import Foundation
import PromiseKit

typealias JSON = [String: AnyObject]

// MARK: - protocol JsonInitializable
protocol JsonInitializable {
    init (json: JSON) throws
}

// MARK: - protocol JsonConvertable
protocol JsonConvertable {
    func toJson() -> JSON
}

// MARK: - enum RouterError
enum RouterError: Error, DisplayableErrorType {
    case dataTypeMismatch
    case serverError(message: String)
    case hiddenError //error message is not shown for some cases like 401

    var errorMessage: String? {
        switch self {
        case .dataTypeMismatch:
            return Localize.Error.Generic
        case .serverError(let message):
            return message
        case .hiddenError:
            return nil
        }
    }
}

// MARK: - protocol DisplayableErrorType
protocol DisplayableErrorType {

    var errorMessage: String? { get }
}

// MARK: - Extension PromiseKit.Error DisplayableErrorType
extension PromiseKit.PMKError: DisplayableErrorType {
    
    var errorMessage: String? {
        switch self {
        default:
            return Localize.Error.Generic
        }
        //TODO: When Case?
    }
}

// MARK: - Extension URLError DisplayableErrorType
extension PromiseKit.PMKHTTPError: DisplayableErrorType {
    

    var errorMessage: String? {
        switch self {
        case .badStatusCode(_, let data, _):
            return errorMessageFromData(data: data) ?? Localize.Error.Generic
        }
    }
    
    func errorMessageFromData(data: Data?) -> String? {
        guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let dict = json as? [String: AnyObject] else {
            return nil
        }
        
        guard let messageDict = dict["error"] as? [String: AnyObject], let messageString = messageDict["message"] as? String else {
            return nil
        }
        
        return messageString
    }

}
