//
//  PaceEditor.swift
//  luffyRun
//
//  Created by laihj on 2023/3/20.
//

import UIKit
import CoreData
import ActionSheetPicker_3_0

class HeartRateEditor: UIViewController {
    var context:NSManagedObjectContext?
    lazy var paceLabel:[UILabel] = [UILabel]()

    var restLabel:UILabel = {
        let label = UILabel()
        label.textColor = .textPrimaryColor
        label.font = .boldSystemFont(ofSize: 22)
        label.isUserInteractionEnabled = true
        return label
    }()
    var maxLabel:UILabel = {
        let label = UILabel()
        label.textColor = .textPrimaryColor
        label.font = .boldSystemFont(ofSize: 22)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    var curHeartRate:HeartRate?
    
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
    
    var minPickerHeart:String?
    var curPickerHeart:String?
    var maxPickerHeart:String?
    var heartRatePickerData:[String]?
    var pickerHeart:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "心率区间"
        self.setupViews()
        
        if let heartRate = HeartRate.lastedHeadRate(in: context!) {
            curHeartRate = heartRate
            self.updateWithHeartRate()
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action:#selector(save(sender:)))
    }
    
    func updateAfterSelected() {
        let rest:Int16? = Int16(restLabel.text ?? "") ?? 0
        let max:Int16? = Int16(maxLabel.text ?? "") ?? 0
        
        let heartRate = HeartRate.insert(into: context!)
        heartRate.rest = rest!
        heartRate.max = max!
        heartRate.calWithReserveMethod()
        curHeartRate = heartRate
        self.updateWithHeartRate()
    }
    
    func updateWithHeartRate() {
        if let curHeartRate = curHeartRate {
            for (index,label) in paceLabel.enumerated() {
                label.text = curHeartRate.formatZone(zone:5 - index)
            }
            restLabel.text = ("\(curHeartRate.rest)")
            maxLabel.text = ("\(curHeartRate.max)")
        }
    }
    
    @objc func save(sender:UIBarButtonItem) {
        if context!.saveOrRollback() {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func paceClicked(tap:UITapGestureRecognizer) {
        let label = tap.view as! UILabel
        restLabel.textColor = .textSecondaryColor
        maxLabel.textColor = .textSecondaryColor
        label.textColor = .purple
        curPickerHeart = label.text
        pickerLabel = label
        if label == restLabel {
            minPickerHeart = "30"
            maxPickerHeart = maxLabel.text
        }
        
        if label == maxLabel {
            minPickerHeart = restLabel.text
            maxPickerHeart = "220"
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

        
        let inputView = UIStackView()
        inputView.axis = .vertical
        inputView.distribution = .equalSpacing
        self.view.addSubview(inputView)
        inputView.snp.makeConstraints({ make in
            make.top.equalTo(colorPaceView.snp.bottom).offset(20)
            make.bottom.equalTo(pickerContainer.snp.top)
            make.height.equalTo(88)
            make.left.equalTo(colorPaceView)
        })
        
        let restView = UIStackView()
        restView.axis = .horizontal
        restView.distribution = .equalSpacing
        restView.spacing = 12
        inputView.addArrangedSubview(restView)
        restView.snp.makeConstraints({ make in
            make.height.equalTo(44)
        })
        
        let rest = UILabel()
        rest.text = "静息心率"
        rest.textColor = .textSecondaryColor
        rest.font = .boldSystemFont(ofSize: 22)
        restView.addArrangedSubview(rest)
        rest.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        restLabel.text = "134"
        restView.addArrangedSubview(restLabel)
        let restTap = UITapGestureRecognizer(target: self, action: #selector(paceClicked(tap:)))
        restLabel.addGestureRecognizer(restTap)
        restLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        
        let maxView = UIStackView()
        maxView.axis = .horizontal
        maxView.distribution = .equalSpacing
        maxView.spacing = 12
        inputView.addArrangedSubview(maxView)
        maxView.snp.makeConstraints({ make in
            make.height.equalTo(44)
        })
        
        let max = UILabel()
        max.text = "最大心率"
        max.textColor = .textSecondaryColor
        max.font = .boldSystemFont(ofSize: 22)
        maxView.addArrangedSubview(max)
        max.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        maxLabel.text = "134"
        let maxTap = UITapGestureRecognizer(target: self, action: #selector(paceClicked(tap:)))
        maxLabel.addGestureRecognizer(maxTap)
        maxView.addArrangedSubview(maxLabel)
        maxLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        _ = self.pickerContainer
    }

}

extension HeartRateEditor:UIPickerViewDelegate,UIPickerViewDataSource {

    func recalPickerData () {
        heartRatePickerData = [String]()
        let minHeart:Int = Int(minPickerHeart ?? "0")!
        let maxHeart:Int = Int(maxPickerHeart ?? "0")!
        for heart in minHeart...maxHeart {
            heartRatePickerData?.append("\(heart)")
        }
        pickerView.selectRow(0, inComponent: 0, animated: false)
    }
    
    func pickerInitSelected(picker:UIPickerView) {
        let heartIndex = heartRatePickerData?.firstIndex(of: String(curPickerHeart!))
        picker.selectRow(heartIndex ?? 0, inComponent: 0, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return heartRatePickerData!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return heartRatePickerData![row]
    }
    
    func pickerView(_ pickerView: UIPickerView,
                  didSelectRow row: Int,
                   inComponent component: Int) {
        pickerHeart = self.pickerView(pickerView, titleForRow: row, forComponent: 0)
        self.updateString()
    }
    
    func updateString (){
        if let label = pickerLabel {
            label.text = "\(pickerHeart!)"
        }
        updateAfterSelected()
    }
}
