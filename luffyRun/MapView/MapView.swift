//
//  MapView.swift
//  luffyRun
//
//  Created by laihj on 2023/1/17.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let region: MKCoordinateRegion
    let lineCoordinates: [CLLocation]
    
    func makeUIView(context: Context) -> some UIView {
        let mapView = MKMapView()
        mapView.region = region
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> () {
        Coordinator()
    }
}

