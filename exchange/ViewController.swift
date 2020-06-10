//
//  ViewController.swift
//  exchange
//
//  Created by Сергей Пономаренко on 30.05.2020.
//  Copyright © 2020 Илья Пономаренко. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var keyIn = ""
    var keyOut = ""
    var dictionary1: [String: Double] = [:]
    var componentArray: [String] = []
    var nameOfValues: [String] = ["RUB", "USD", "EUR"]
    @IBOutlet weak var inLabel: UILabel!
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var out: UILabel!
    @IBOutlet weak var from: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView1.delegate = self
        self.tableView1.dataSource = self
        self.tableView2.delegate = self
        self.tableView2.dataSource = self
        getvalue()
    }
    func getvalue() {
        guard let url = URL(string: "https://api.exchangeratesapi.io/latest") else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if (error != nil) {
                print("error")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                    self.getvalue()
                })
            }
            guard let data = data else { return }
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            print(json?["rates"])
            self.dictionary1 = json?["rates"]! as! [String : Double]
            self.componentArray = Array(self.dictionary1.keys)
            for i in self.componentArray {
                if i != "USD" && i != "RUB" {
                    self.nameOfValues.append(i)
                }
            }
            DispatchQueue.main.async {
                self.tableView1.reloadData()
                self.tableView2.reloadData()
            }
        }.resume()
    }
    
    func change() {
        DispatchQueue.main.async {
            if self.from.text != "" {
                let inValue = self.from.text!
                let EUR: Double
                if self.keyIn != "EUR" {
                    EUR = Double(inValue)! / self.dictionary1[self.keyIn]!
                } else {
                    EUR = Double(inValue)!
                }
                if self.keyOut != "EUR" {
                    self.out.text = String(round(EUR * self.dictionary1[self.keyOut]! * 100)/100) + " " + self.keyOut
                } else {
                    self.out.text = String(round(EUR * 100)/100) + " " + self.keyOut
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dictionary1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableView1 {
            let cell = tableView1.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) 
            cell.textLabel!.text = nameOfValues[indexPath.row]
            cell.textLabel!.textColor = UIColor.white
            return cell
        } else if tableView == tableView2 {
            let cell = tableView2.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            cell.textLabel!.text = nameOfValues[indexPath.row]
            cell.textLabel!.textColor = UIColor.white
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableView1 {
            keyIn = nameOfValues[indexPath.row]
            DispatchQueue.main.async {
                self.inLabel.text = self.keyIn
            }
            if keyOut != "" {
                change()
            }
        }
        if tableView == tableView2 {
            keyOut = nameOfValues[indexPath.row]
            if keyIn != "" {
                change()
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func edited(_ sender: Any) {
        if keyIn != "" && keyOut != "" {
            change()
        }
    }
}

