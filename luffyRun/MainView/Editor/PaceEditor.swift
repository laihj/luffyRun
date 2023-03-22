//
//  PaceEditor.swift
//  luffyRun
//
//  Created by laihj on 2023/3/20.
//

import UIKit
import CoreData
import ActionSheetPicker_3_0

class PaceEditor: UIViewController {
    var context:NSManagedObjectContext?
    lazy var paceLabel:[UILabel] = [UILabel]()
    
    
    var pickerMinte:String?
    var pickerSecond:String?
    var pickerLabel:UILabel?
    
    lazy var pickerContainer = {
        let stackView = UIStackView()
        stackView.backgroundColor = .white
        stackView.axis = .vertical
        stackView.spacing = 0
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        let toolView = UIView()
        stackView.addArrangedSubview(toolView)
        toolView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        return stackView
    }()
    
    lazy var pickerView = {
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerContainer.addArrangedSubview(pickerView)
        return pickerView
    }()
    
    var minPickerPace:String?
    var curPickerPace:String?
    var maxPickerPace:String?
    var minitePickerData:[String]?
    var secondPickerData:[String:[String]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "配速区间"
        
        let paceRate = PaceZone.lastedPaceZone(in: context!)
        
        self.setupViews()
        for (index,label) in paceLabel.enumerated() {
            label.text = paceRate?.formatZone(zone:5 - index)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action:#selector(save(sender:)))
    }
    
    @objc func save(sender:UIBarButtonItem) {
        self.context!.performChanges {
            let paceRate = PaceZone.insert(into: self.context!)
            for (index,label) in self.paceLabel.enumerated() {
                if(index == 0) {
                    paceRate.zone4 = Int16(self.secondFormString(min: label.text!))
                } else if (index == 1) {
                    paceRate.zone3 = Int16(self.secondFormString(min: label.text!))
                } else if (index == 2) {
                    paceRate.zone2 = Int16(self.secondFormString(min: label.text!))
                } else if (index == 3) {
                    paceRate.zone1 = Int16(self.secondFormString(min: label.text!))
                }
            }
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func paceClicked(tap:UITapGestureRecognizer) {
        let label = tap.view as! UILabel
        for allLabel in self.paceLabel {
            allLabel.textColor = .gray
        }
        label.textColor = .purple
        curPickerPace = label.text
        pickerLabel = label
        if let preLabel = self.paceLabel.before(label) {
            minPickerPace = preLabel.text
        } else {
            minPickerPace = "2'40''"
        }
        
        if let nextLabel = self.paceLabel.after(label) {
            maxPickerPace = nextLabel.text
        } else {
            maxPickerPace = "9'59''"
        }
        
        self.recalPickerData()
        self.pickerView.reloadAllComponents()
        self.pickerInitSelected(picker: pickerView)
        
        
        UIView.animate(withDuration: 0.2, animations: {
            self.pickerContainer.snp.remakeConstraints {
                $0.left.right.equalTo(0)
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
            self.view.layoutIfNeeded()
        })
        
    }
    
    func setupViews() {
        let colorPaceView = UIStackView()
        colorPaceView.axis = .vertical
        colorPaceView.distribution = .fillEqually
        self.view.addSubview(colorPaceView)
        colorPaceView.layer.cornerRadius = 10;
        colorPaceView.layer.masksToBounds = true
        colorPaceView.backgroundColor = .green
        colorPaceView.snp.makeConstraints { make in
            make.width.equalTo(80);
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.bottom.equalTo(pickerContainer.snp.top)
        }
        
        let zoneColor:[UIColor] = [.zone5Color,.zone4Color,.zone3Color,.zone2Color,.zone1Color];
        let zoneTitle:[String] = ["zone5","zone4","zone3","zone2","zone1"];
        for (index,color) in zoneColor.enumerated() {
            let view = UIView()
            view.backgroundColor = color
            
            let title = UILabel()
            title.textColor = .white
            title.font = UIFont.boldSystemFont(ofSize: 14)
            title.textAlignment = .center
            title.text = zoneTitle[index]
            view.addSubview(title)
            title.snp.makeConstraints { make in
                make.edges.equalTo(0)
            }
            
            colorPaceView.addArrangedSubview(view)
        }
        
        let labelView = UIStackView()
        labelView.axis = .vertical
        labelView.distribution = .fillEqually
        labelView.backgroundColor = .clear
        view.addSubview(labelView);
        labelView.snp.makeConstraints { make in
            make.left.equalTo(colorPaceView.snp_rightMargin).offset(30)
            make.centerY.equalTo(colorPaceView)
            make.height.equalTo(colorPaceView).multipliedBy(0.8)
            make.width.equalTo(100);
        };
        
        for _ in 0...3 {
            let title = UILabel()
            title.textColor = .gray
            title.font = UIFont.boldSystemFont(ofSize: 24)
            title.textAlignment = .left
            title.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(paceClicked(tap:)))
            title.addGestureRecognizer(tap)
            labelView.addArrangedSubview(title)
            paceLabel.append(title)
        }
        
        let lineView = UIStackView()
        lineView.axis = .vertical
        lineView.distribution = .equalSpacing
        self.view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.centerY.equalTo(colorPaceView)
            make.left.equalTo(colorPaceView.snp_rightMargin).offset(3)
            make.right.equalTo(labelView.snp_leftMargin).offset(-2)
            make.height.equalTo(colorPaceView).multipliedBy(0.6)
            make.centerX.equalTo(view)
        }
        
        for _ in 0...3 {
            let line = UIView()
            line.backgroundColor = .gray
            line.snp.makeConstraints { make in
                make.height.equalTo(1)
            }
            lineView.addArrangedSubview(line)
        }
        _ = self.pickerContainer
        

    }
    

}

extension PaceEditor:UIPickerViewDelegate,UIPickerViewDataSource {

    func recalPickerData () {
        minitePickerData = [String]()
        secondPickerData = [String:[String]]()
        let minSecond = secondFormString(min: minPickerPace!)
        let maxSecond = secondFormString(min: maxPickerPace!)
        for second in (minSecond+1)..<maxSecond {
            let minite = "\(second/60)"
            let second = "\(second%60)"
            if !minitePickerData!.contains(minite) {
                minitePickerData?.append(minite)
            }
            
            if var secondDict = secondPickerData?[minite] {
                secondDict.append(second)
                secondPickerData![minite] = secondDict
            } else {
                let secondDict = [second]
                secondPickerData![minite] = secondDict
            }
        }
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.selectRow(0, inComponent: 1, animated: false)
    }
    
    func pickerInitSelected(picker:UIPickerView) {
        let stringArray = curPickerPace!.split(separator: "'")
        guard stringArray.count == 2 else { return}
        let minite = stringArray.first
        pickerMinte = String(minite!)
        let second = stringArray.last
        pickerSecond = String(second!)
        let miniteIndex = minitePickerData?.firstIndex(of: String(minite!))
        let seconds = secondPickerData![String(minite!)]
        let secondIndex = seconds?.firstIndex(of: String(second!))
        picker.selectRow(miniteIndex ?? 0, inComponent: 0, animated: true)
        picker.selectRow(secondIndex ?? 0, inComponent: 1, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return minitePickerData!.count
        } else {
            let index = pickerView.selectedRow(inComponent: 0)
            let minite = minitePickerData![index]
            let seconds = secondPickerData![minite]
            return seconds!.count
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return minitePickerData![row]
        } else {
            let index = pickerView.selectedRow(inComponent: 0)
            let minite = minitePickerData![index]
            let seconds = secondPickerData![minite]
            return seconds![row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView,
                  didSelectRow row: Int,
                   inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
            pickerMinte = self.pickerView(pickerView, titleForRow: row, forComponent: 0)
            let index = pickerView.selectedRow(inComponent: 1)
            pickerSecond = self.pickerView(pickerView, titleForRow: index, forComponent: 1)
        } else {
            pickerSecond = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        }
        self.updateString()
    }
    
    func updateString (){
        if let label = pickerLabel {
            label.text = "\(pickerMinte!)'\(pickerSecond!)''"
        }
        print("\(pickerMinte!)'\(pickerSecond!)''")
    }
    
    func secondFormString(min:String) -> Int {
        let stringArray = min.split(separator: "'")
        guard stringArray.count == 2 else { return 0 }
        return Int(stringArray.first!)! * 60 + Int(stringArray.last!)!
    }
}
