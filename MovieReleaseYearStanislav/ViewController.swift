//
//  ViewController.swift
//  MovieReleaseYearStanislav
//
//  Created by Stanislav Stajila on 1/12/24.
//
//
//1. Create a struct (Movie) that adopts the Codable protocol
//2. Make instance variables with names that match the keys you want from the json object
//3. Use JSONDecoder.decode to create object after getting data in ViewController class

//If there is an Array as a value:
// 1. Create another struct (Rating) with the keys of the array as instance variables
// 2. Create an instance variable in the original struct with Array type of new struct [Rating]
// 3. Now you can access elements in the array


struct Movie: Codable{
    // same name as a key!!!
    var Actors: String
    var Country: String
    var Director: String
    var Metascore: String
    var Ratings: [Rating]
}

struct Rating: Codable{
    var Source: String
    var Value: String
}

struct MovieSearch: Codable{
    var Title: String
    var Year: String
}

struct SearchResults: Codable{
    var Search: [MovieSearch]
}

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var releasedDateLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchResultsTextBox: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getMovieInfo()
        getMovies()
    }
    
    
    func getMovies(){
        
        let session = URLSession.shared
        // put s (in this API) for - Movie title to search for.
        let movieURL = URL(string: "http://www.omdbapi.com/?i=tt3896198&apikey=cafd33a0&s=ghost")
        
        let dataTask = session.dataTask(with: movieURL!) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let e = error{
                print("Error: \(e)")
            } else{
                if let d = data{
                    if let jsonObj = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as? NSDictionary{
                        print(jsonObj)
                        
                        if let searchObj = try? JSONDecoder().decode(SearchResults.self, from: d){
                            for movie in searchObj.Search{
                                print("\(movie.Title): \(movie.Year)")
                            }
                        } else{
                            print("error decoding to movie object")
                        }
                    }
                    
                }
                
            }
            
            
        }
        
        dataTask.resume()
        
        
    }
    
    func getMovieInfo(){
        
        let session = URLSession.shared
        
        // t stands for (in this API) - movie title to search for.
        let movieURL = URL(string: "http://www.omdbapi.com/?i=tt3896198&apikey=cafd33a0&api&t=ghost")
        
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
                    //Use JSONDecoder.decode to create object after getting data in ViewController class
                    if let movieObj = try? JSONDecoder().decode(Movie.self, from: d){
                        print(movieObj.Actors)
                        
                        for r in movieObj.Ratings{
                            print("\(r.Source)   \(r.Value)")
                        }
                    } else{
                        print("error decoding to movie object")
                    }
                }
                
            }
            
            
        }
        
        dataTask.resume()
        
        
    }
    
    
    @IBAction func search(_ sender: Any) {
        searchResultsTextBox.text = ""
        if searchTextField.text != ""{
            searchForTheMovie()
        } else{
            searchResultsTextBox.textColor = UIColor.red
            searchResultsTextBox.text = "Type something to search!"
        }
    }
    
    func searchForTheMovie(){
        let session = URLSession.shared
        let movieURL = URL(string: "http://www.omdbapi.com/?i=tt3896198&apikey=cafd33a0&api&s=\(searchTextField.text!.lowercased())")
        
        let dataTask = session.dataTask(with: movieURL!){
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if let e = error{
                print("Error: \(e)")
            }else{
                if let d = data {
                    if let jsonObj = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as? NSDictionary{
                        print(jsonObj)
                        if let response = jsonObj.value(forKey: "Response") as? String{
                            if response == "True"{
                                if let movieObj = try? JSONDecoder().decode(SearchResults.self, from: d){
                                    var res = ""
                                    for movie in movieObj.Search{
                                        if movie.Title.lowercased() == self.searchTextField.text!.lowercased() {
                                             res = "\(movie.Title): \(movie.Year)\n"
                                            break
                                        }

                                    }
                                    
                                    DispatchQueue.main.async{
                                        if res == ""{
                                            self.searchResultsTextBox.textColor = UIColor.red
                                            self.searchResultsTextBox.text = "No movie found!"
                                        } else{
                                            self.searchResultsTextBox.textColor = UIColor.black
                                            self.searchResultsTextBox.text = res
                                        }
                                    }
                                    
                                    }
                                }
                            } else{
                                DispatchQueue.main.async{
                                    if let error = jsonObj.value(forKey: "Error") as? String{
                                        DispatchQueue.main.async{
                                            self.searchResultsTextBox.textColor = UIColor.red
                                            self.searchResultsTextBox.text += error
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        dataTask.resume()
        }
    }
