//
//  ViewController.swift
//  hepsiburada
//
//  Created by Niyazi Tanyeri on 19.04.2016.
//  Copyright © 2016 Niyazi Tanyeri. All rights reserved.
//

import UIKit
import FoursquareAPI
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, FoursquareAPIDelegate
{
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Constats
    let locationManager = CLLocationManager()
    
    // MARK: Variables
    var foursquareAPI       : FoursquareAPI!
    var userLocation        : CLLocationCoordinate2D?
    var searchController    : UISearchController!
    var venues              = [Venue]()
    
    // MARK: - Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        sendUserLocationRequest()
        prepareSearchController()
        prepareUIAppearance()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UISearchBar Delegate Methods
    func searchBarSearchButtonClicked( searchBar: UISearchBar)
    {
        if let query = self.searchController.searchBar.text
        {
            switch searchController.searchBar.selectedScopeButtonIndex
            {
            case 0:
                foursquareAPI.sendVenueSearchRequest(query, intent: Intent.CheckIn)
                break
            case 1:
                foursquareAPI.sendVenueSearchRequest(query, intent: Intent.Global)
                break
            default:
                break
            }
        }
    }
    
    // MARK: - FoursquareAPI Delegate
    func foursquareVenuesAPIDidRequestSuccess(venues: [Venue], endpoint: VenuesEndpoints)
    {
        self.venues = venues
        tableView.reloadData()
    }
    
    func foursquareVenuesAPIDidRequestFailure(errors: NSError?, endpoint: VenuesEndpoints)
    {
        
    }
    
    // MARK: - UITableView DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return venues.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let venue = venues[indexPath.row]
        
        cell.textLabel?.text = venue.name
        cell.detailTextLabel?.text = "Distance: \(venue.location.distance) meters"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Functions
    func sendUserLocationRequest()
    {
        locationManager.delegate = self
        
        if (CLLocationManager.locationServicesEnabled())
        {
            print("Location Service: Enable")
            switch CLLocationManager.authorizationStatus()
            {
            case .NotDetermined:
                print("NotDetermined")
                locationManager.requestWhenInUseAuthorization()
            case .AuthorizedWhenInUse:
                print("AuthorizedWhenInUse")
            case .Denied:
                print("Denied")
            case .Restricted:
                print("Restricted")
            case .AuthorizedAlways:
                print("AuthorizedAlways")
            }
        }
    }
    
    func prepareUIAppearance()
    {
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func prepareSearchController()
    {
        let scopeTitles         = ["Near", "Global"]
        self.searchController   = UISearchController(searchResultsController: nil)
        
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.delegate                = self
        self.searchController.searchBar.placeholder             = "Search for Places"
        self.searchController.searchBar.scopeButtonTitles       = scopeTitles
        self.searchController.searchBar.userInteractionEnabled  = false
        
        self.searchController.delegate                              = self
        self.searchController.hidesNavigationBarDuringPresentation  = false
        self.searchController.dimsBackgroundDuringPresentation      = false
        
        self.tableView.tableHeaderView      = searchController.searchBar
        self.tableView.keyboardDismissMode  = UIScrollViewKeyboardDismissMode.OnDrag
        definesPresentationContext          = true
    }
    
    // MARK: - CoreLocation Delegate Methods
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        locationManager.stopUpdatingLocation()
        
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locationArray   = locations as NSArray
        let locationObj     = locationArray.lastObject as! CLLocation
        let coordinate      = locationObj.coordinate
        locationManager.stopUpdatingLocation()
        
        userLocation = coordinate
        self.searchController.searchBar.userInteractionEnabled = true
        
        foursquareAPI = FoursquareAPI(userCoordinate: coordinate)
        foursquareAPI.delegate = self
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        switch status
        {
        case .AuthorizedWhenInUse:
            print("AuthorizedWhenInUse")
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            break
        case .Denied:
            print("Denied")
            
            let alertController = UIAlertController(title: "Location Service", message: "Please allow access to location services", preferredStyle: UIAlertControllerStyle.Alert)
            
            let dismissAction   = UIAlertAction(title: "Yoksay", style: UIAlertActionStyle.Cancel, handler: nil)
            let settingsAction  = UIAlertAction(title: "Ayarlar", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            })
            alertController.addAction(dismissAction)
            alertController.addAction(settingsAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        default:
            break
        }
    }

}

