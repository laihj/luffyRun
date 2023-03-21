//
//  RunningDetailVC.swift
//  luffyRun
//
//  Created by laihj on 2022/10/13.
//

import UIKit
import HealthKit
import Charts
import SnapKit
import SwiftUI
import MapKit

class RunningDetailVC: UIViewController {
    fileprivate var observer: ManagedObjectObserver?
    fileprivate var mapView: MKMapView!
    fileprivate var routeOverlay : MKOverlay?
    
    var barDatas:[BarData]?
    
    var record:Record! {
        didSet {
            observer = ManagedObjectObserver(object: record, changeHandler: { [weak self] type in
                guard type == .delete else { return }
                _ = self?.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    var lastRecord:Record?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action:#selector(deleteRecord(sender:)))
        self.setupViews()
        // Do any additional setup after loading the view.
        if let routes = record.routes, let _ = routes.first  {
            self.drawRoute(routes: routes)
//            mapView.centerToLocation(firstNode.location)
        }
        
        record.events?.forEach({ event in
            if event.type == .segment {
                print("\(event.startDate) - \(event.endDate) = \(event.endDate.timeIntervalSince(event.startDate))")
            }
            
        })
        
    }
    
    func drawRoute(routes: [RouteNode]) {
        if routes.count == 0 {
            print("🟡 No Coordinates to draw")
            return
        }
        
        let coordinates = routes.map { (route) -> CLLocationCoordinate2D in
            let wgs84Point = route.location.coordinate
            if JZAreaManager.default.isInArea(gcj02Point: wgs84Point) {
                let offsetPoint = wgs84Point.gcj02Offset()
                let resultPoint = CLLocationCoordinate2DMake(wgs84Point.latitude + offsetPoint.latitude, wgs84Point.longitude + offsetPoint.longitude)
                return resultPoint
            } else {
                return wgs84Point
            }
        }
        
        DispatchQueue.main.async {
            self.routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
            let customEdgePadding: UIEdgeInsets = UIEdgeInsets(top: 60, left: 50, bottom: UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.width, right: 50)
            self.mapView.setVisibleMapRect(self.routeOverlay!.boundingMapRect, edgePadding: customEdgePadding, animated: false)
            self.mapView.addOverlay(self.routeOverlay!, level: .aboveLabels)
        }
    }
    
    func setupViews() {
        
        self.mapView = MKMapView()
        self.mapView.delegate = self
        self.mapView.pointOfInterestFilter = .excludingAll
        self.mapView.preferredConfiguration = MKStandardMapConfiguration(emphasisStyle: .muted)
        self.mapView.isZoomEnabled = false
        self.view.addSubview(self.mapView)
        mapView.snp.makeConstraints { make in
            make.top.right.left.equalTo(0)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        let chart = SwiftChart(record: record, lastRecord: lastRecord)
        let hostingContrller = UIHostingController(rootView:chart)
        hostingContrller.view.backgroundColor = .clear
        self.addChild(hostingContrller)
        self.view.addSubview(hostingContrller.view)
        hostingContrller.view.snp.makeConstraints { make in
            make.top.right.left.equalTo(0)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        self.updateViews()

    }
    
    func updateViews () {
    }
    
    @objc
    func deleteRecord(sender: UIBarButtonItem) {
        record.managedObjectContext?.performChanges(block: {
            self.record.managedObjectContext?.delete(self.record)
        })
        print("delete mode")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 5000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

extension RunningDetailVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKGradientPolylineRenderer(overlay: overlay)
        renderer.setColors([
            UIColor(red: 0.02, green: 0.91, blue: 0.05, alpha: 1.00),
            UIColor(red: 1.00, green: 0.48, blue: 0.00, alpha: 1.00),
            UIColor(red: 1.00, green: 0.00, blue: 0.00, alpha: 1.00)
        ], locations: [])
        renderer.lineCap = .round
        renderer.lineWidth = 2.5
        return renderer
    }
}

extension CLLocationCoordinate2D {
    struct JZConstant {
        static let A = 6378245.0
        static let EE = 0.00669342162296594323
    }
    func gcj02Offset() -> CLLocationCoordinate2D {
        let x = self.longitude - 105.0
        let y = self.latitude - 35.0
        let latitude = (-100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))) +
                        ((20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0) +
                            ((20.0 * sin(y * .pi) + 40.0 * sin(y / 3.0 * .pi)) * 2.0 / 3.0) +
                                ((160.0 * sin(y / 12.0 * .pi) + 320 * sin(y * .pi / 30.0)) * 2.0 / 3.0)
        let longitude = (300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))) +
                            ((20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0) +
                                ((20.0 * sin(x * .pi) + 40.0 * sin(x / 3.0 * .pi)) * 2.0 / 3.0) +
                                    ((150.0 * sin(x / 12.0 * .pi) + 300.0 * sin(x / 30.0 * .pi)) * 2.0 / 3.0)
        let radLat = 1 - self.latitude / 180.0 * .pi;
        var magic = sin(radLat);
        magic = 1 - JZConstant.EE * magic * magic
        let sqrtMagic = sqrt(magic);
        let dLat = (latitude * 180.0) / ((JZConstant.A * (1 - JZConstant.EE)) / (magic * sqrtMagic) * .pi);
        let dLon = (longitude * 180.0) / (JZConstant.A / sqrtMagic * cos(radLat) * .pi);
        return CLLocationCoordinate2DMake(dLat, dLon);
    }
}
