//
//  LocationManager.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 12/10/22.
//

import Foundation
import MapKit

class LocationManager: NSObject {
    
    static let managerObj = LocationManager()
//    private var routePolylineArray: [MKRoute] = []
    typealias CompletionHandler = (_ route:MKRoute?) -> Void
    private var isMapRectLoaded = false
    private var currentOverlay : MKOverlay?
    private var oldLocPlaceMark: MKPlacemark?;
    
    //------- new logic -------
    var driverAnnotation: MKPointAnnotation?
    var pickupAnnotation: MKPointAnnotation?
    var dropAnnotation: MKPointAnnotation?
    var routeDrawn = false
    var isFollowingDriver = true
    private var lastDriverCoordinate: CLLocationCoordinate2D?
    /// Bearing in degrees (0 = north, 90 = east) based on driver movement
    private(set) var driverBearing: CLLocationDegrees = 0
    // ------- end -------
    
    private override init() {
        super.init()
    }
    
    func parseLocationObj(mapItem: MKMapItem) -> MapLocation {
        var mapLocation = MapLocation()
        if let name = mapItem.name {
            mapLocation.name = name
        }
        
        if let phoneNumber = mapItem.phoneNumber {
            mapLocation.phoneNumber = phoneNumber
        }
        
        mapLocation.address = getFormattedAddress(placemark: mapItem.placemark)
        
        if let location = mapItem.placemark.coordinate as CLLocationCoordinate2D? {
            mapLocation.latitude = location.latitude
            mapLocation.longitude = location.longitude
        }
        
        return mapLocation
    }
    
    func parseLocationPlaceMark(placemark: CLPlacemark, isCurrentLocation: Bool) -> MapLocation {
        var maploc = MapLocation()
        var name = placemark.name
        let address = getFormattedAddress(placemark: placemark)
        if isCurrentLocation {
            name = "Your Location: \(address)"
        }
        maploc.name = name
        maploc.address = address
        if let loc = placemark.location {
            maploc.latitude = loc.coordinate.latitude
            maploc.longitude = loc.coordinate.longitude
        }
        return maploc
    }
    
    func addAnnotationOnMap(searchMode: Bool = true, mapview: MKMapView, locationArray: [MapLocation]) {
        mapview.removeAnnotations(mapview.annotations)
        Logger.shared.log("#NOT_USED# addAnnotationOnMap", level: .warn)
        for location in locationArray {
            let annotation = MKPointAnnotation()
            annotation.subtitle = ""
            if location.name == locationArray.first?.name {
                annotation.subtitle = "NearByDriver"
                if searchMode {
                    annotation.subtitle = "Start"
                }
            }
           /* TO show alll stops */
//            else {
//                annotation.subtitle = "Stop"
//            }
            if location.name == locationArray.last?.name {
                annotation.subtitle = "Start"
                if searchMode {
                    annotation.subtitle = "Stop"
                }
            }
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!)
            mapview.addAnnotation(annotation)
        }
    }
    
    
    func addAnnotationOnMapFromPassangerToEndRide(mapview: MKMapView, locationArray: [MapLocation]) {
           //mapview.removeAnnotations(mapview.annotations)
//        mapview.annotations.removeAll { annote in
//            locationArray.contains { maplocation in
//                annote.coordinate.latitude != maplocation.latitude && annote.coordinate.longitude != maplocation.longitude
//            }
//        }
        Logger.shared.log("addAnnotationOnMapFromPassangerToEndRide", level: .error)
        mapview.annotations.forEach { annote in
           if !(locationArray.contains { maploc in
                annote.coordinate.latitude == maploc.latitude && annote.coordinate.longitude == maploc.longitude
           }) {
               Logger.shared.log(" --- Removed Annotation: \(annote.coordinate.latitude), \(annote.coordinate.longitude)", level: .info)
               mapview.removeAnnotation(annote)
           }
        }
        
        print("##ANNOTE##: \(mapview.annotations.count)")
        
           for location in locationArray {
               let annotation = MKPointAnnotation()
               annotation.subtitle = ""
               if location.name == locationArray.first?.name {
                   annotation.subtitle = "NearByDriver"
               }
   //            else {
   //                annotation.subtitle = "Stop"
   //            }
               if location.name == locationArray.last?.name {
                       annotation.subtitle = "Stop"
               }
               annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!)
               if !(mapview.annotations.contains(where: { annote in
                   annote.coordinate.latitude == annotation.coordinate.latitude && annote.coordinate.longitude == annotation.coordinate.longitude
               })) {
                   Logger.shared.log("+++ Added Annotation: \(annotation.coordinate.latitude), \(annotation.coordinate.longitude)", level: .info)
                   mapview.addAnnotation(annotation)
               }
           }
    }
    
    func addCarAnnotationOnMap(mapview: MKMapView, driversLocationArray: [CLLocationCoordinate2D]) {
        mapview.removeAnnotations(mapview.annotations)
        for location in driversLocationArray {
            let annotation = MKPointAnnotation()
            annotation.subtitle = "NearByDriver"
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude:location.longitude)
            mapview.addAnnotation(annotation)
        }
    }
    
    func clearOverlay(mapView: MKMapView) {
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
    }

    
//    func showRouteOnMap(mapView: MKMapView, locationArray: [MapLocation]) {
////        routePolylineArray.removeAll()
//        self.clearOverlay(mapView: mapView)
//        Logger.shared.log("** showRouteOnMap ** ", level: .error)
//        
//        var mapRect = MKMapRect()
//        var totalETATime = 0.0
//        for locationObj in locationArray {
//            let index = locationArray.firstIndex(of: locationObj)
//            if index != locationArray.count - 1 {
//                let nextIndex = index! + 1
//                let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationObj.latitude)!, longitude: (locationObj.longitude)!))
//                let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationArray[nextIndex].latitude)!, longitude: (locationArray[nextIndex].longitude)!))
//                getRouteBetween(source: sourcePlaceMark, destination: destPlaceMark, completionHandler: {route in
//                    if route != nil {
//                        //self.routePolylineArray.append(route!)
//                        totalETATime = totalETATime + (route?.expectedTravelTime ?? 0)
//                        print("Route dist: \(route?.distance) \n route desc: \(route?.description) \n ETA: \(route?.expectedTravelTime) \t Total ETA: \(totalETATime)")
//                        Logger.shared.log("Route dist: \(route?.distance) \n Route desc: \(route?.description) \n ETA: \(route?.expectedTravelTime) \t Route Total ETA: \(totalETATime)", level: .error)
//                        self.calculateETATimeFrom(timeInSec: totalETATime)
//                        let distInMiles = route?.distance.convert(from: UnitLength.meters, to: UnitLength.miles) ?? "0.0"
//                        print("\(route?.distance) - in miles \(distInMiles)")
//                        UserDefaults.standard.setValue("\(distInMiles)", forKey: "ESTIMATED_DISTANCE_OF_TRAVEL")
//                        mapView.addOverlay(route!.polyline)
//                        mapView.setVisibleMapRect(route!.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 40.0, left: 40.0, bottom: 500.0, right: 40.0), animated: true)
//                        mapRect = mapView.visibleMapRect.union(route!.polyline.boundingMapRect)
//                        self.isMapRectLoaded = true
//                        self.currentOverlay = route?.polyline
//                    }
//                })
//            }
//            if index == locationArray.count - 1 && isMapRectLoaded {
//                mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets.init(top: 20.0, left: 40.0, bottom: 400.0, right: 40.0), animated: true)
//            }
//            
//        }
//    }
//
    
    // Add these properties to your class
    private var isUpdatingRoute = false
    private var hasInitiallyZoomed = false
    private var lastMapRect: MKMapRect?

    func showRouteOnMap(mapView: MKMapView, locationArray: [MapLocation], padding: UIEdgeInsets? = nil) {
        // Prevent concurrent updates
        guard !isUpdatingRoute else {
            Logger.shared.log("Route update already in progress, skipping...", level: .warn)
            return
        }
        
        isUpdatingRoute = true
        Logger.shared.log("** showRouteOnMap ** ", level: .error)
        
        var combinedMapRect: MKMapRect?
        var totalETATime = 0.0
        var newOverlays: [MKOverlay] = []
        let dispatchGroup = DispatchGroup()
        
        for locationObj in locationArray {
            guard let index = locationArray.firstIndex(of: locationObj),
                  index != locationArray.count - 1 else { continue }
            
            let nextIndex = index + 1
            let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(
                latitude: locationObj.latitude!,
                longitude: locationObj.longitude!
            ))
            let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(
                latitude: locationArray[nextIndex].latitude!,
                longitude: locationArray[nextIndex].longitude!
            ))
            
            dispatchGroup.enter()
            getRouteBetween(source: sourcePlaceMark, destination: destPlaceMark) { route in
                defer { dispatchGroup.leave() }
                
                guard let route = route else { return }
                
                totalETATime += route.expectedTravelTime
                Logger.shared.log("Route dist: \(route.distance) | ETA: \(route.expectedTravelTime) | Total ETA: \(totalETATime)", level: .error)
                
                let distInMiles = route.distance.convert(from: UnitLength.meters, to: UnitLength.miles) ?? "0.0"
                UserDefaults.standard.setValue("\(distInMiles)", forKey: "ESTIMATED_DISTANCE_OF_TRAVEL")
                NotificationCenter.default.post(name: NSNotification.Name("UpdatedDistance"), object: distInMiles)
                
                newOverlays.append(route.polyline)
                
                if combinedMapRect == nil {
                    combinedMapRect = route.polyline.boundingMapRect
                } else {
                    combinedMapRect = combinedMapRect!.union(route.polyline.boundingMapRect)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.calculateETATimeFrom(timeInSec: totalETATime)
            
            // Clear old overlays and add new ones
            self.clearOverlay(mapView: mapView)
            
            if !newOverlays.isEmpty {
                mapView.addOverlays(newOverlays)
                
                if let finalMapRect = combinedMapRect {
                    // Only zoom if this is the first time OR if the map rect changed significantly
                    let shouldZoom = !self.hasInitiallyZoomed || self.hasMapRectChangedSignificantly(newRect: finalMapRect)
                    
                    if shouldZoom {
                        let finalPadding = padding ?? UIEdgeInsets(top: 60.0, left: 60.0, bottom: 450.0, right: 60.0)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            mapView.setVisibleMapRect(
                                finalMapRect,
                                edgePadding: finalPadding,
                                animated: !self.hasInitiallyZoomed // Only animate after first load
                            )
                        }
                        self.hasInitiallyZoomed = true
                        self.lastMapRect = finalMapRect
                    }
                    
                    self.isMapRectLoaded = true
                }
            }
            
            self.isUpdatingRoute = false
        }
    }

    // Helper function to check if map rect changed significantly
    private func hasMapRectChangedSignificantly(newRect: MKMapRect) -> Bool {
        guard let lastRect = lastMapRect else { return true }
        
        // Calculate the difference in size (you can adjust the threshold)
        let widthDiff = abs(newRect.size.width - lastRect.size.width)
        let heightDiff = abs(newRect.size.height - lastRect.size.height)
        
        // Calculate the difference in origin
        let originXDiff = abs(newRect.origin.x - lastRect.origin.x)
        let originYDiff = abs(newRect.origin.y - lastRect.origin.y)
        
        // Threshold: 20% change in size or significant position change
        let sizeChangeThreshold = lastRect.size.width * 0.2
        let positionChangeThreshold = lastRect.size.width * 0.1
        
        return widthDiff > sizeChangeThreshold ||
               heightDiff > sizeChangeThreshold ||
               originXDiff > positionChangeThreshold ||
               originYDiff > positionChangeThreshold
    }
    
    func updateDriverAnnotation(mapView: MKMapView, newCoordinate: CLLocationCoordinate2D, completion: (() -> Void)? = nil) {
        // Calculate bearing from previous position to new position
        if let prev = self.lastDriverCoordinate {
            self.driverBearing = bearing(from: prev, to: newCoordinate)
        }
        
        if let annotation = self.driverAnnotation {
            UIView.animate(withDuration: 1.5, delay: 0, options: .curveLinear, animations: {
                annotation.coordinate = newCoordinate
            }, completion: { _ in
                completion?()
            })
        } else {
            let annotation = MKPointAnnotation()
            annotation.subtitle = "NearByDriver"
            annotation.coordinate = newCoordinate
            self.driverAnnotation = annotation
            mapView.addAnnotation(annotation)
            completion?()
        }
        self.lastDriverCoordinate = newCoordinate
    }

    /// Calculates compass bearing in degrees from one coordinate to another.
    private func bearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDegrees {
        let lat1 = start.latitude * .pi / 180
        let lat2 = end.latitude * .pi / 180
        let dLon = (end.longitude - start.longitude) * .pi / 180

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radianBearing = atan2(y, x)
        return (radianBearing * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
    }

    // Add this function to reset when starting a new trip
    func resetMapZoom() {
        hasInitiallyZoomed = false
        lastMapRect = nil
        driverAnnotation = nil
        lastDriverCoordinate = nil
    }
        
    func showRouteOnMapAnimationNew(_ mapView: MKMapView, with locations: [MapLocation]) {
        guard locations.count >= 2 else { return }
        
        clearOverlay(mapView: mapView)
        
        var mapRect = MKMapRect.null
        var totalETATime = 0.0
        var routeCount = 0
        
        let group = DispatchGroup()

        for index in 0..<(locations.count - 1) {
            group.enter()
            let source = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: locations[index].latitude!, longitude: locations[index].longitude!))
            let dest = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: locations[index + 1].latitude!, longitude: locations[index + 1].longitude!))
            
            getRouteBetween(source: source, destination: dest) { route in
                if let route = route {
                    totalETATime += route.expectedTravelTime
                    mapView.addOverlay(route.polyline)
                    mapRect = mapRect.union(route.polyline.boundingMapRect)
                    routeCount += 1
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if routeCount > 0 {
                self.calculateETATimeFrom(timeInSec: totalETATime)
                mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 300, right: 40), animated: true)
            }
        }
    }
    
    private func calculateETATimeFrom(timeInSec: Double) {
        if timeInSec != 0 {
            var timeIntervalInMin = Int(timeInSec / 60)
            var timeIntervalInHour = 0
            if timeIntervalInMin >= 60 {
                timeIntervalInHour = Int(timeIntervalInMin / 60)
                timeIntervalInMin = timeIntervalInMin - (timeIntervalInHour * 60)
            }
            let eta = timeIntervalInHour == 0 ? "\(timeIntervalInMin) min" :  timeIntervalInMin == 0 ? timeIntervalInHour == 1 ? "\(timeIntervalInHour) hr" : "\(timeIntervalInHour) hrs" : timeIntervalInHour == 1 ? "\(timeIntervalInHour) hr \(timeIntervalInMin) min" : "\(timeIntervalInHour) hrs \(timeIntervalInMin) min"
            
            // Calculate Arrival Clock Time
            let arrivalDate = Date().addingTimeInterval(timeInSec)
            let arrivalFormatter = DateFormatter()
            arrivalFormatter.dateFormat = "h:mm a"
            let arrivalTimeStr = arrivalFormatter.string(from: arrivalDate)
            
            NotificationCenter.default.post(name: NSNotification.Name("UpdatedETA"), object: eta)
            
            UserDefaults.standard.setValue(eta, forKey: "ESTIMATED_TIME_FOR_TRAVEL")
            
            if let dist = UserDefaults.standard.string(forKey: "ESTIMATED_DISTANCE_OF_TRAVEL") {
                 let combinedInfo = ["eta": eta, "distance": dist, "arrival_time": arrivalTimeStr]
                 NotificationCenter.default.post(name: NSNotification.Name("UpdatedTripInfo"), object: combinedInfo)
            }
        }else{
            NotificationCenter.default.post(name: NSNotification.Name("UpdatedETA"), object: "Reaching")
        }
    }
    
    /* All Private Methods */
    private func getFormattedAddress(placemark: CLPlacemark) -> String {
        let address = "\(placemark.subThoroughfare ?? "NO Content") \(placemark.thoroughfare ?? "NO Content"), \(placemark.locality ?? "NO Content"), \(placemark.administrativeArea ?? "NO Content"), \(placemark.postalCode ?? "NO Content"), \(placemark.country ?? "NO Content")"
        let baseFormat = address.components(separatedBy: "NO Content, ").joined()
        let formattedAddress = baseFormat.components(separatedBy: "NO Content ").joined()
        
        return formattedAddress;
    }
    
    private func getRouteBetween(source: MKPlacemark, destination: MKPlacemark, completionHandler: @escaping CompletionHandler) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: source)
        request.destination = MKMapItem(placemark: destination)
        //request.requestsAlternateRoutes = true
        request.transportType = [.automobile]
        var route: MKRoute?
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "No error specified").")
                return
            }
            
            route = response.routes[0]
            completionHandler(route)
        }
    }
    
    func showRouteWithCarMovingAnimationOnMap(mapView: MKMapView, locationArray: [MapLocation], isFirstTime: Bool = false) {
        
        var totalETATime = 0.0
        var mapRect = MKMapRect()
        
        if (isFirstTime) {
            self.clearOverlay(mapView: mapView)
            
            for locationObj in locationArray {
                let index = locationArray.firstIndex(of: locationObj)
                if index != locationArray.count - 1 {
                    let nextIndex = index! + 1
                    let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationObj.latitude)!, longitude: (locationObj.longitude)!))
                    oldLocPlaceMark = sourcePlaceMark;
                    let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationArray[nextIndex].latitude)!, longitude: (locationArray[nextIndex].longitude)!))
                    getRouteBetween(source: sourcePlaceMark, destination: destPlaceMark, completionHandler: {route in
                        if route != nil {
                            //self.routePolylineArray.append(route!)
                            totalETATime = totalETATime + (route?.expectedTravelTime ?? 0)
                            print("Route dist: \(route?.distance) \n route desc: \(route?.description) \n ETA: \(route?.expectedTravelTime) \t Total ETA: \(totalETATime)")
                            self.calculateETATimeFrom(timeInSec: totalETATime)
                            let distInMiles = route?.distance.convert(from: UnitLength.meters, to: UnitLength.miles) ?? "0.0"
                            print("\(route?.distance) - in miles \(distInMiles)")
                            UserDefaults.standard.setValue("\(distInMiles)", forKey: "ESTIMATED_DISTANCE_OF_TRAVEL")
                            mapView.addOverlay(route!.polyline)
                           // mapView.setVisibleMapRect(route!.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 40.0, left: 40.0, bottom: 500.0, right: 40.0), animated: true)
                            mapRect = mapView.visibleMapRect.union(route!.polyline.boundingMapRect)
                            self.isMapRectLoaded = true
                            self.currentOverlay = route?.polyline
                            print("#### Count: \(mapView.overlays.count) OverLays: \(mapView.overlays[0].coordinate)")
                        }
                    })
                }
                if index == locationArray.count - 1 && isMapRectLoaded {
                    mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets.init(top: 20.0, left: 40.0, bottom: 400.0, right: 40.0), animated: true)
                }
            }
        }else{
            for locationObj in locationArray {
                let index = locationArray.firstIndex(of: locationObj)
                if index != locationArray.count - 1 {
                    let nextIndex = index! + 1
                    let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationObj.latitude)!, longitude: (locationObj.longitude)!))
                    let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationArray[nextIndex].latitude)!, longitude: (locationArray[nextIndex].longitude)!))
                    getRouteBetween(source: sourcePlaceMark, destination: destPlaceMark, completionHandler: {route in
                        if route != nil {
                            totalETATime = totalETATime + (route?.expectedTravelTime ?? 0);
                            
                            print("Route dist: \(route?.distance) \n route desc: \(route?.description) \n ETA: \(route?.expectedTravelTime) \t Total ETA: \(totalETATime)")
                            
                            self.calculateETATimeFrom(timeInSec: totalETATime);
                            let distInMiles = route?.distance.convert(from: UnitLength.meters, to: UnitLength.miles) ?? "0.0"
                            
                            print("\(route?.distance) - in miles \(distInMiles)")
                            UserDefaults.standard.setValue("\(distInMiles)", forKey: "ESTIMATED_DISTANCE_OF_TRAVEL")
                            mapView.addOverlay(route!.polyline)
                            
                            mapRect = mapView.visibleMapRect.union(route!.polyline.boundingMapRect)
                            
                            self.isMapRectLoaded = true
                            
                            self.currentOverlay = route?.polyline
                            
                            print("#### Count: \(mapView.overlays.count) OverLays: \(mapView.overlays[0].coordinate)")
                        }
                    })
                    
                    getRouteBetween(source: oldLocPlaceMark!, destination: sourcePlaceMark, completionHandler: {route in
                        if route != nil {
                            mapView.addOverlay(route!.polyline)
//                            mapRect = mapView.visibleMapRect.union(route!.polyline.boundingMapRect)
//                            self.isMapRectLoaded = true
//                            
//                            self.currentOverlay = route?.polyline
//
                        }
                    })
                }
            }
        }
        
    }
}

