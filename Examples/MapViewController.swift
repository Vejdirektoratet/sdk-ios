//
//  ViewController.swift
//  Examples
//
//  Created by Daniel Andersen on 05/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import UIKit
import MapKit
import VejdirektoratetSDK

class MapViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    
    let apiKey = "<TODO>" // TODO! Retrieve key from https://nap.vd.dk/register and paste it here

    var currentListRequest: HTTP.Request? = nil
    var currentMapRequest: HTTP.Request? = nil

    var updateMapTimer: Timer? = nil
    
    var listEntities: [Entity] = []
    var mapEntities: [Entity] = []
    
    var selectedMapMarker: MapMarker? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.register(MarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateMapData()
        self.updateTableView()
    }
    
    // MARK: Feed

    func updateTableView() {
        self.currentListRequest?.cancel()

        self.currentListRequest = VejdirektoratetSDK.request(entityTypes: [.Traffic, .RoadWork, .TrafficDensity],
                                                             region: self.mapView.region,
                                                             viewType: .List,
                                                             apiKey: self.apiKey) { result in
            DispatchQueue.main.async {
                switch result {
                case .entities(let entities):
                    self.listEntities = entities
                    self.tableView.reloadData()
                case .error(let error):
                    debugPrint("Error: \(error)")
                default:
                    break
                }
            }
        }
    }
    
    func updateMapData() {
        self.currentMapRequest?.cancel()

        self.currentMapRequest = VejdirektoratetSDK.request(entityTypes: [.Traffic, .RoadWork, .TrafficDensity],
                                                            region: self.mapView.region,
                                                            viewType: .Map,
                                                            apiKey: self.apiKey) { result in
            DispatchQueue.main.async {
                switch result {
                case .entities(let entities):
                    self.mapEntities = entities
                    self.redrawMap()
                    self.updateTableView()
                    self.statusLabel.text = "Map updated: \(NSDate())"
                case .error(let error):
                    self.handleError(error: error)
                default:
                    break
                }
                
                self.updateMapTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false, block: { timer in
                    self.updateMapData()
                    self.updateMapTimer = nil
                })
            }
        }
    }
    
    func handleError(error: Feed.RequestError) {
        self.statusLabel.text = "Unknown error"

        switch error {
        case .ServerError(_, let message):
            if message != nil {
                self.statusLabel.text = "Error: \(message!)"
            }
        }
    }
    
    // MARK: Map drawing

    func redrawMap() {

        // Remove everything from map
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)

        // Add entities
        for entity in self.mapEntities {
            let mapModel = entity as! MapEntity
            switch mapModel.type {
            case .marker:
                self.addMapMarker(marker: mapModel as! MapMarker)
            case .polyline:
                self.addPolyline(polyline: mapModel as! MapPolyline)
            case .polygon:
                self.addPolygon(polygon: mapModel as! MapPolygon)
            }
        }
    }
    
    func addMapMarker(marker: MapMarker) {
        let mapMarker = MarkerAnnotation(mapMarker: marker)
        self.mapView.addAnnotation(mapMarker)
    }
    
    func addPolyline(polyline: MapPolyline) {
        let overlay = PolylineOverlay(mapPolyline: polyline)
        self.mapView.addOverlay(overlay)
    }
    
    func addPolygon(polygon: MapPolygon) {
        let overlay = PolygonOverlay(mapPolygon: polygon)
        self.mapView.addOverlay(overlay)
    }

    // MARK: MKMapViewDelegate
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.updateMapTimer?.invalidate()
        self.updateMapTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
            self.updateMapData()
            self.updateMapTimer = nil
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? PolylineOverlay {
            let renderer = MKPolylineRenderer(polyline: overlay.polyline)
            renderer.strokeColor = overlay.mapPolyline.style.strokeColor
            renderer.lineWidth = CGFloat(overlay.mapPolyline.style.strokeWidth)
            return renderer
        }
        if let overlay = overlay as? PolygonOverlay {
            let renderer = MKPolygonRenderer(polygon: overlay.polygon)
            renderer.strokeColor = overlay.mapPolygon.style.strokeColor
            renderer.lineWidth = CGFloat(overlay.mapPolygon.style.strokeWidth)
            renderer.fillColor = overlay.mapPolygon.style.fillColor
            return renderer
        }
        fatalError("Something wrong...")
    }
    
    func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
        let mapMarker = (view.annotation as? MarkerAnnotation)?.mapMarker
        if mapMarker != nil {
            self.selectedMapMarker = mapMarker
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "mapToDetailsSegue", sender: self)
            }
        }
    }

    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listEntities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listModel = self.listEntities[indexPath.row] as! ListEntity

        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.backgroundColor = UIColor.init(white: 1.0, alpha: 0.0)
        cell.textLabel?.text = listModel.heading

        return cell
    }

    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let listModel = self.listEntities[indexPath.row] as! ListEntity
        
        for annotation in self.mapView.annotations {
            let mapMarker = (annotation as? MarkerAnnotation)?.mapMarker
            if mapMarker != nil && mapMarker!.tag == listModel.tag {
                self.selectedMapMarker = mapMarker
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.performSegue(withIdentifier: "mapToDetailsSegue", sender: self)
                }
                DispatchQueue.main.async {
                    self.mapView.setRegion(MKCoordinateRegion(center: mapMarker!.center,
                                                              latitudinalMeters: 5000,
                                                              longitudinalMeters: 5000),
                                           animated: true)
                }
                return
            }
        }
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.selectedMapMarker == nil {
            return
        }

        let entityViewController = segue.destination as! EntityViewController
        entityViewController.entityTag = self.selectedMapMarker!.tag
        entityViewController.apiKey = self.apiKey

        self.selectedMapMarker = nil
    }
}



class MarkerAnnotation: NSObject, MKAnnotation {
    let mapMarker: MapMarker
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let imageUrl: String?
  
    init(mapMarker: MapMarker) {
        self.mapMarker = mapMarker
        self.title = "\(mapMarker.entityType)"
        self.coordinate = mapMarker.center
        self.imageUrl = mapMarker.style.icon
        
        super.init()
    }
}

class MarkerView: MKAnnotationView {
    var urlTask: URLSessionDataTask? = nil
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let markerAnnotation = newValue as? MarkerAnnotation else { return }
            
            self.image = nil
            if let imageUrl = markerAnnotation.imageUrl {
                self.imageFromServerURL(urlString: imageUrl)
            }
        }
    }
    
    func imageFromServerURL(urlString: String) {
        self.urlTask?.cancel()

        self.urlTask = URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) in
            if error != nil {
                debugPrint("Error loading image: \(error!)")
                return
            }
            DispatchQueue.main.async(execute: {
                self.image = UIImage.resize(image: UIImage(data: data!)!, size: CGSize(width: 40, height: 40))
            })
            
        })
        self.urlTask?.resume()
    }
}



class PolylineOverlay: NSObject, MKOverlay {
    var boundingMapRect: MKMapRect
    let title: String?
    let coordinate: CLLocationCoordinate2D

    public let polyline: MKPolyline
    public let mapPolyline: MapPolyline
    
    init(mapPolyline: MapPolyline) {
        self.mapPolyline = mapPolyline
        self.polyline = MKPolyline.init(coordinates: mapPolyline.points, count: mapPolyline.points.count)

        self.title = "\(mapPolyline.entityType)"
        self.boundingMapRect = self.polyline.boundingMapRect
        self.coordinate = self.polyline.coordinate
    }
}



class PolygonOverlay: NSObject, MKOverlay {
    var boundingMapRect: MKMapRect
    let title: String?
    let coordinate: CLLocationCoordinate2D

    public let polygon: MKPolygon
    public let mapPolygon: MapPolygon
    
    init(mapPolygon: MapPolygon) {
        self.mapPolygon = mapPolygon
        self.polygon = MKPolygon.init(coordinates: mapPolygon.points, count: mapPolygon.points.count)

        self.title = "\(mapPolygon.entityType)"
        self.boundingMapRect = self.polygon.boundingMapRect
        self.coordinate = self.polygon.coordinate
    }
}
