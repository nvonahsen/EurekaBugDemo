//
//  ViewController.swift
//  EurekaDemo

import Eureka
import UIKit

class ViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        createForm()
    }
    
    // Clears and rebuilds form
    func createForm() {
        // BUG - when this runs the rows are removed properly, however,
        // The observer that hides/shows displayRow is not removed from the form's rowObservers array
        // This means that there is:
        //      a) an extra observer in the rowObservers that shouldn't be there any more
        //      b) still a reference to displayRow, meaning it continues to exist and observe changes/leak memory
        // To repro just run the app, then hit "Rebuild form" a few times,
        // now open the xcode memory explorer and expand the Eureka section, there will be a pile of instances of TextRow
        form.removeAll()
        
        form +++ Section("Display")
            // A simple text row (could be any kind of row) which is hidden based on a switch row
            <<< TextRow("displayRow") { row in
                row.title = "Text Row"
                row.hidden = Condition.function(["ShowHideRow"], { form in
                    ((form.rowBy(tag: "ShowHideRow") as? SwitchRow)?.value ?? false)
                })
            }
            <<< SwitchRow("ShowHideRow")

            // Button row that re-runs this function to recreate the form (for testing the issue)
            +++ Section("Test")
            <<< ButtonRow("rebuild") { row in
                row.title = "Rebuild form"
                row.onCellSelection { [weak self] _, _ in
                    self?.createForm()
                }
            }
    }
}

