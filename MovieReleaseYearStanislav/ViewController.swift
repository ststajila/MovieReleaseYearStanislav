//
//  ViewController.swift
//  MovieReleaseYearStanislav
//
//  Created by Stanislav Stajila on 1/12/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var releasedDateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getMovie()
    }


    func getMovie(){
        
        let session = URLSession.shared
        let movieURL = URL(string: "http://www.omdbapi.com/?i=tt3896198&apikey=cafd33a0")
        
        let dataTask = session.dataTask(with: movieURL!) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let e = error{
                print("Error: \(e)")
            } else{
                if let d = data{
                    if let jsonObj = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as? NSDictionary{
                        
                        print(jsonObj)
                        if let released = jsonObj.value(forKey: "Released") as? String{
                            DispatchQueue.main.async{
                                self.releasedDateLabel.text = "\(released)"
                            }
                                                 }
                    }
                }
            }
            
            
        }
        
        dataTask.resume()
    }
}

