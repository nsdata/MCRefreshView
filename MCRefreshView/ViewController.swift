//
//  ViewController.swift
//  MCRefreshView
//
//  Created by zhmch0329 on 15/12/14.
//  Copyright © 2015年 zhmch0329. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var dataSource = [String]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let footer = MCRefreshBackNormalFooter()
        footer.refreshingClosure = { (header) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(5.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                self.reloadData()
                if self.dataSource.count > 33 {
                    footer.endRefreshingWithNoMoreData()
                } else {
                    footer.endRefreshing()
                }
            }
        }
        tableView.footer = footer
        
        let header = MCRefreshNormalHeader()
        header.refreshingClosure = {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                self.count = 0
                self.dataSource.removeAll()
                self.reloadData()
                footer.resetNoMoreData()
                header.endRefreshing()
            }
        }
        tableView.header = header
        

        tableView.header?.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate var count = 0
    fileprivate var pageIndex = 1
    fileprivate func reloadData() {
        var array = [String]()
        let y = pageIndex * 5 + 1
        
        for i in count ..< y {
            array.append("第\(i)行")
        }
        count += 5
        pageIndex += 1
        self.dataSource.append(contentsOf: array)
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let Identifier: String = "Identifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: Identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: Identifier)
        }
        cell?.textLabel?.text = dataSource[indexPath.row]
        return cell!
    }
    
    

}

