//
//  EntityViewController.swift
//  Examples
//
//  Created by Daniel Andersen on 07/01/2020.
//  Copyright © 2020 Vejdirektoratet. All rights reserved.
//

import UIKit
import VejdirektoratetSDK

class EntityViewController: UIViewController {
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    public var entityTag: String = ""
    public var apiKey: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        VejdirektoratetSDK.requestEntity(tag: self.entityTag, viewType: VejdirektoratetSDK.ViewType.List, apiKey: self.apiKey) { result in
            DispatchQueue.main.async {
                switch result {
                case .entity(let entity):
                    let listModel = entity as! ListEntity
                    self.headingLabel.text = listModel.heading
                    self.descriptionTextView.text = listModel.description
                    debugPrint(entity.tag)
                case .error(let error):
                    self.headingLabel.text = "Error"
                    self.descriptionTextView.text = "\(error)"
                default:
                    break
                }
            }
        }
    }
}
