//
//  StoreFinderViewController.swift
//  Music Practice
//
//  Created by William Haslet on 12/14/22.
//

import UIKit
import MapKit

class StoreFinderViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
            locationManager.requestLocation()
            
        } else {
           // Do something to let users know why they need to turn it on.
        }
    }
    
    func checkLocationAuthorization() {
      switch CLLocationManager.authorizationStatus() {
      case .authorizedWhenInUse:
        mapView.showsUserLocation = true
          break
       case .denied: // Show alert telling users how to turn on permissions
       break
      case .notDetermined:
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
      case .restricted: // Show an alert letting them know what’s up
       break
      case .authorizedAlways:
       break
      }
    }
    
    func performSearch(_ searchRegion: MKCoordinateRegion) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Music store"
        request.region = searchRegion
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response, error) in
            
            if let results = response {
            
                if let err = error {
                    print("Error occurred in search: \(err.localizedDescription)")
                } else if results.mapItems.count == 0 {
                    print("No matches found")
                } else {
                    print("Matches found")
                    
                    let maxLocations = 10
                    var pinCount = 0
                    
                    for item in results.mapItems {
                        print("Name = \(item.name ?? "No match")")
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = item.placemark.coordinate
                        annotation.title = item.name
                        self.mapView.addAnnotation(annotation)
                        
                        pinCount += 1
                        if (pinCount >= maxLocations)
                        {
                            break
                        }
                    }
                }
            }
        })
    }
    
    func openInMaps(_ annotation: MKAnnotation?)
    {
        let latitude: CLLocationDegrees = Double(annotation!.coordinate.latitude)
        let longitude: CLLocationDegrees = Double(annotation!.coordinate.longitude)
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = annotation?.title ?? "Location"
        mapItem.openInMaps(launchOptions: options)
    }
}

extension StoreFinderViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            performSearch(region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        
    }
}

extension StoreFinderViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation)
        {
            return nil
        }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped: UIControl) {
        openInMaps(annotationView.annotation)
    }
}
