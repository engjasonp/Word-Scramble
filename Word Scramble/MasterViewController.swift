//
//  MasterViewController.swift
//  Word Scramble
//
//  Created by Jason Eng on 7/20/15.
//  Copyright (c) 2015 EngJason. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var allWords = [String]()
    var objects = [String]()


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "promptForAnswer")
        if let startWordsPath = NSBundle.mainBundle().pathForResource("start", ofType: "txt") {
            if let startWords = NSString(contentsOfFile: startWordsPath, usedEncoding: nil, error: nil) {
                allWords = startWords.componentsSeparatedByString("\n") as! [String]
            } else {
                loadDefaultWords()
            }
        } else {
            allWords = ["silkworm"]
        }
        startGame()
    }
    
    func loadDefaultWords() {
        allWords = ["zucchini"]
    }
    
    func startGame() {
        allWords.shuffle()
        title = allWords[0]
        objects.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler(nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self, ac] (action: UIAlertAction!) in
            let answer = ac.textFields![0] as! UITextField
            self.submitAnswer(answer.text.lowercaseString)
        }
        
        ac.addAction(submitAction)
        
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func submitAnswer(answer: String) {
        
        if wordIsPossible(answer) {
            if wordIsOriginal(answer) {
                if (answer == title) {
                    showErrorMessage("Unoriginal word", message: "Be more original!")
                }
                
                if wordIsReal(answer) {
                    objects.insert(answer, atIndex: 0)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                } else {
                    showErrorMessage("Word not recognised", message: "You can't just make them up, you know!")
                }
            } else {
                showErrorMessage("Word used already", message: "Be more original!")            }
        } else {
            showErrorMessage("Word not possible", message: "You can't spell that word from '\(title!.lowercaseString)'!")
        }
    }
    
    func showErrorMessage(title: String!, message: String!) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
        return
    }
    
    func wordIsPossible(word: String) -> Bool {
        var tempWord = title!.lowercaseString
        
        for letter in word {
            if let pos = tempWord.rangeOfString(String(letter)) {
                if pos.isEmpty {
                    return false
                } else {
                    tempWord.removeAtIndex(pos.startIndex)
                }
            } else {
                return false
            }
        }
        
        return true
    }
    
    func wordIsOriginal(word: String) -> Bool {
        return !contains(objects, word)
    }
    
    func wordIsReal(word: NSString) -> Bool {
        if (word.length < 3) {
            return false
        }
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.length)
        let misspelledRange = checker.rangeOfMisspelledWordInString(word as String, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }

}

