//
//  Result.swift
//  DemoCurl
//
//  Created by Tang Tianyong on 8/16/16.
//  Copyright © 2016 Tianyong Tang. All rights reserved.
//

/**
 The result of request.

 Every request may return two possible statuses: `.success` or `.failure`.
 */
public enum Result {
    case success(response: Response)
    case failure(error: Error)
}
