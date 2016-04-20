//
//  FoursquareAPI.swift
//  hepsiburada
//
//  Created by Niyazi Tanyeri on 19.04.2016.
//  Copyright © 2016 Niyazi Tanyeri. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

// MARK: - Protocol
public protocol FoursquareAPIDelegate
{
    func foursquareVenuesAPIDidRequestSuccess(venues: [Venue], endpoint: VenuesEndpoints)
    func foursquareVenuesAPIDidRequestFailure(errors: NSError?, endpoint: VenuesEndpoints)
}

// MARK: - Class
public class FoursquareAPI
{
    // MARK: - Constant
    static let clientID     = "V4V3OWGTZRYYBT1Z4UTE4NRPLICLZOHMCO25PLY3HZTWN01I"
    static let clientSecret = "BHADAKJHCG4E2B53QXQ5YVRY2MP3GEBSBDCBDCEWC4LOVQWZ"
    
    // MARK: Variables
    public var delegate    : FoursquareAPIDelegate?
    var coordinate  : CLLocationCoordinate2D
    var requireParamaters = ["client_id": clientID, "client_secret": clientSecret, "v": "20140806", "m": "foursquare"]
    
    // MARK: - Initialization
    public init(userCoordinate: CLLocationCoordinate2D)
    {
        self.coordinate = userCoordinate
        requireParamaters["ll"] = "\(userCoordinate.latitude), \(userCoordinate.longitude)"
    }
    
    // MARK: - API Functions
    public func sendVenueSearchRequest(query: String, intent: Intent)
    {
        let endpoint = VenuesEndpoints.Search
        requireParamaters["query"]  = query
        requireParamaters["intent"] = intent.rawValue
        
        let request = Alamofire.request(.GET, endpoint.URL, parameters: requireParamaters).validate().responseJSON { (response) in
            if response.result.isSuccess
            {
                let jsonObject = JSON(response.result.value!)
                
                let venues = self.parseVanues(jsonObject["response"])
                self.delegate?.foursquareVenuesAPIDidRequestSuccess(venues, endpoint: endpoint)
            }
            else
            {
                self.delegate?.foursquareVenuesAPIDidRequestFailure(response.result.error, endpoint: endpoint)
            }
        }
        
        print(request)
    }
    
    // MARK: - API Utils
    func parseVanues(venuesData: JSON) -> [Venue]
    {
        var result = [Venue]()
        
        if let venues = venuesData["venues"].arrayValue as [JSON]?
        {
            for venue in venues
            {
                var categoryData = [Category]()
                
                if let categories = venue["categories"].arrayValue as [JSON]?
                {
                    for category in categories
                    {
                        categoryData.append(Category(
                            id          : category["id"].stringValue,
                            name        : category["id"].stringValue,
                            pluralName  : category["id"].stringValue,
                            shortName   : category["id"].stringValue,
                            icon        : NSURL(),
                            primary     : category["id"].boolValue))
                    }
                }
                
                result.append(Venue(
                    id          : venue["id"].stringValue,
                    name        : venue["name"].stringValue,
                    verified    : venue["verified"].boolValue,
                    referralId  : venue["referralId"].stringValue,
                    stats       : Stat(
                        checkinsCount   : venue["stats"]["checkinsCount"].doubleValue,
                        usersCount      : venue["stats"]["usersCount"].doubleValue,
                        tipCount        : venue["stats"]["tipCount"].doubleValue),
                    categories  : categoryData,
                    location    : Location(
                        address     : venue["location"]["address"].stringValue,
                        crossStreet : venue["location"]["crossStreet"].stringValue,
                        coordinate  : CLLocationCoordinate2DMake(venue["location"]["lat"].doubleValue, venue["location"]["lng"].doubleValue),
                        distance    : venue["location"]["distance"].doubleValue,
                        cc          : venue["location"]["cc"].stringValue,
                        city        : venue["location"]["city"].stringValue,
                        country     : venue["location"]["country"].stringValue),
                    contact     : Contact(
                        phone           : venue["contact"]["phone"].stringValue,
                        formattedPhone  : venue["contact"]["formattedPhone"].stringValue)))
            }
        }
        
        return result
    }
}


// MARK: - Enum
public enum VenuesEndpoints: String
{
    static let baseURL = NSURL(string: "https://api.foursquare.com/v2/venues/")

    case Search = "search"
    
    var URL: NSURL{
        return NSURL(string: self.rawValue, relativeToURL: VenuesEndpoints.baseURL)!
    }
}

public enum Intent: String
{
    case CheckIn    = "checkin"
    case Browse     = "browse"
    case Global     = "global"
    case Match      = "match"
}