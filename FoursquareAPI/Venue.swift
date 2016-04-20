//
//  Venue.swift
//  hepsiburada
//
//  Created by Niyazi Tanyeri on 19.04.2016.
//  Copyright © 2016 Niyazi Tanyeri. All rights reserved.
//

import Foundation
import CoreLocation

public struct Venue
{
    public let id          : String
    public let name        : String
    public let verified    : Bool
    public let referralId  : String
    public let stats       : Stat
    public let categories  : [Category]
    public let location    : Location
    public let contact     : Contact
}

public struct Contact
{
    public let phone           : String
    public let formattedPhone  : String
}

public struct Location
{
    public let address             : String
    public let crossStreet         : String
    public let coordinate          : CLLocationCoordinate2D
    public let distance            : Double
    public let cc                  : String
    public let city                : String
    public let country             : String
}

public struct Category
{
    public let id          : String
    public let name        : String
    public let pluralName  : String
    public let shortName   : String
    public let icon        : NSURL
    public let primary     : Bool
}

public struct Stat
{
    public let checkinsCount   : Double
    public let usersCount      : Double
    public let tipCount        : Double
}

