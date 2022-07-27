//
//  ViewController.swift
//  CryptoPricePredictor
//
//  Created by Nguyen Tran on 7/20/22.
//

import UIKit
import TwitterAPIKit
import Twift
import CoreML

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        predictButton.layer.cornerRadius = predictButton.frame.height / 2
        authTwitterUser()
        
//        async {
//            await testExample()
//        }
        
    }
    @IBOutlet weak var predictButton: UIButton!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var symbolTextField: UITextField!
    // make a singleton later. lazy now
    var client:Twift?
    let maximumTweets = 100
    
    
    @IBAction func predictButtonDidTap(_ sender: UIButton) {
        view.endEditing(true)
        sentimentLabel.text = ""
        guard let key = symbolTextField.text, key != ""
        else {
            return
        }
        
        // start fecting
        async {
            let data = await fetchTweets(key: key)
            let score = predict(data: data)
            updateUI(analyzedScore: score)
        }
    }
    func fetchTweets(key: String) async -> [TextClassifierInput]?{
        do {
            guard let result = try await client?.searchRecentTweets(query: "@\(key) lang:en", maxResults: maximumTweets)
            else {
                return nil
            }
            
            // input type of predict funcion
            var tweetsText = [TextClassifierInput]()
            
            for tweet in result.data {
                tweetsText.append(TextClassifierInput(text: tweet.text))
            }
            return tweetsText
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func predict(data: [TextClassifierInput]?) ->Int?{
        guard let data = data
        else {
            return nil
        }
        
        let model = TextClassifier()
        guard let predictionOutput = try? model.predictions(inputs: data)
        else {
            return nil
        }
        var analyzedScore = 0
        for output in predictionOutput {
            if output.label == "Neg" {
                analyzedScore -= 1
            }
            else if output.label == "Pos" {
                analyzedScore += 1
            }
        }
        return analyzedScore
    }
    func updateUI(analyzedScore: Int?) {
        guard let analyzedScore = analyzedScore else {
            return
        }

        if analyzedScore > 20 {
            sentimentLabel.text = "Overwhelmingly positive"
        } else if analyzedScore > 10 {
            sentimentLabel.text = "Very positive"
        } else if analyzedScore > 0 {
            sentimentLabel.text = "Somewhat positive"
        } else if analyzedScore == 0 {
            sentimentLabel.text = "Neutral"
        } else if analyzedScore  < -20 {
            sentimentLabel.text = "Overwhelmingly negative"
        } else if analyzedScore < -10 {
            sentimentLabel.text = "Very negative"
        } else {
            sentimentLabel.text = "Somewhat Negative"
        }
    }
    
    
    func authTwitterUser() {
        // App-Only Bearer Token
        client = Twift(appOnlyBearerToken: "AAAAAAAAAAAAAAAAAAAAAC43fAEAAAAAEeIhxxeDueqeJGDWWiZMT4b68N4%3DTiedVm3mwVWDUCbRWZFwyg04V4RvAEuPzLGMX25tIEBRJ0FMMD")
    }
    
    func testExample() async{
        do {
            guard let result = try await client?.searchRecentTweets(query: "@eth lang:en", maxResults: maximumTweets)
            else {
                return
            }
            
            // input type of predict funcion
            var tweetsText = [TextClassifierInput]()
            
            for tweet in result.data {
                tweetsText.append(TextClassifierInput(text: tweet.text))
            }
            // model
            let model = TextClassifier()
            guard let predictionOutput = try? model.predictions(inputs: tweetsText)
            else {
                return
            }
            // got the label
            var analyzedScore = 0
            
            for output in predictionOutput {
//                print(output.label)
                if output.label == "Neg" {
                    analyzedScore -= 1
                }
                else if output.label == "Pos" {
                    analyzedScore += 1
                }
            }
            // analyze now
            print(analyzedScore)
            
            //
            
            if analyzedScore > 20 {
                sentimentLabel.text = "Overwhelmingly positive"
            } else if analyzedScore > 10 {
                sentimentLabel.text = "Very positive"
            } else if analyzedScore > 0 {
                sentimentLabel.text = "Somewhat positive"
            } else if analyzedScore == 0 {
                sentimentLabel.text = "Neutral"
            } else if analyzedScore  < -20 {
                sentimentLabel.text = "Overwhelmingly negative"
            } else if analyzedScore < -10 {
                sentimentLabel.text = "Very negative"
            } else {
                sentimentLabel.text = "Somewhat Negative"
            }
            print(sentimentLabel.text)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
}

