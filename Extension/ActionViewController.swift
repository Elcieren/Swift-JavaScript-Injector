//
//  ActionViewController.swift
//  Extension
//
//  Created by Eren Elçi on 7.11.2024.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    @IBOutlet var script: UITextView!
    var pageTitle = ""
    var pageUrl = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveCode))
        navigationItem.rightBarButtonItems = [navigationItem.rightBarButtonItem!, saveButton]
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(rastgeleCode))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageUrl = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                        self?.loadSavedCode()
                    }
                }
            }
        }
    }
    func loadSavedCode() {
           if let savedCode = UserDefaults.standard.string(forKey: pageUrl) {
               script.text = savedCode
           }
       }
    
    @objc func saveCode() {
            guard !pageUrl.isEmpty else { return }
            UserDefaults.standard.set(script.text, forKey: pageUrl)
            
            let alert = UIAlertController(title: "Başarıyla Kaydedildi", message: "Kodunuz bu site için kaydedildi.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
        }

    @IBAction func done() {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument ]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    @objc func rastgeleCode(){
        let ac = UIAlertController(title: "Sizin icin Öneri", message: "Assagida rastegele onerilen  JavaScript kodlariyla yapabilceklerinizi deneyimleyebilirsiniz", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Sayfada Yavaşça Aşağı Kaydırma", style: .default, handler: { action in
            self.script.text = "setInterval(() => { document.body.style.backgroundColor = \"#\" + Math.floor(Math.random()*16777215).toString(16); }, 1000);"
        }))
        
        ac.addAction(UIAlertAction(title: "Yavaş Yavaş Kaybolma Efekti", style: .default, handler: { action in
            self.script.text = """
                               var opacity = 1;
                             setInterval(() => {
                            if (opacity > 0) {
                              opacity -= 0.05;
                             document.body.style.opacity = opacity;
                               }
                            }, 100);
                           """
        }))
        
        present(ac, animated: true)
    }

}
