//
//  ViewController.swift
//  SQLiteFmdbApp
//
//  Created by user129308 on 4/11/18.
//  Copyright © 2018 Tecsup. All rights reserved.
//

import UIKit
import FMDB

class ViewController: UIViewController {

    @IBOutlet weak var modeloInput: UITextField!
    
    @IBOutlet weak var precioInput: UITextField!
    
    @IBOutlet weak var buscarInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create tables first time
        initializeTables()
        
    }
    
    // https://github.com/ccgus/fmdb
    
    func loadDatabase() -> FMDatabase {
        let fileURL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("concesionario.sqlite")
        return FMDatabase(url: fileURL)
    }
    
    func initializeTables(){
        
        // 0: Load database
        let database = loadDatabase()
        
        // 1: Open database
        guard database.open() else {
            showAlert(withTitle: "Error Database", withMessage: "Error al abrir base de datos")
            return
        }
        
        do {
            
            // 2: Create Tables
            try database.executeUpdate("CREATE TABLE IF NOT EXISTS autos (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, modelo VARCHAR NOT NULL, precio INTEGER NOT NULL)", values: nil)
            
            let rs = try database.executeQuery("SELECT * FROM autos", values: nil)
            if rs.next() == false {
                // 3: Insert some rows
                try database.executeUpdate("INSERT INTO autos (modelo, precio) VALUES (?, ?)", values: ["Mazda", 20000])
                try database.executeUpdate("INSERT INTO autos (modelo, precio) VALUES (?, ?)", values: ["Honda", 30000])
            }
            
        } catch {
            showAlert(withTitle: "Error Update", withMessage: error.localizedDescription)
        }
        
        // 5: Close database
        database.close()
        
    }
    
    @IBAction func guardar(_ sender: UIButton) {
        
        if(!modeloInput.hasText || !precioInput.hasText){
            showAlert(withTitle: "Error", withMessage: "Debe completar todos los campos")
            return
        }
        
        // 0: Load database
        let database = loadDatabase()
        
        // 1: Open database
        guard database.open() else {
            showAlert(withTitle: "Error Database", withMessage: "Error al abrir base de datos")
            return
        }
        
        // Activar ForeignKey (Si es que es necesario)
        //database.executeUpdate("PRAGMA foreign_keys = ON", withArgumentsIn: nil)
        
        do {
        
            // 2: Create SQL
            let query = "INSERT INTO autos (modelo, precio) VALUES (?, ?)"
            
            // 3: Execute Query
            try database.executeUpdate(query, values: [modeloInput.text!, precioInput.text!])
        
        } catch {
            showAlert(withTitle: "Error Update", withMessage: error.localizedDescription)
        }
            
        // 5: Close database
        database.close()
        
        // Clear form
        modeloInput.text = ""
        precioInput.text = ""
 
        // Alert
        showAlert(withTitle: "Success", withMessage: "Registro guardado")
    
    }
    
    @IBAction func buscar(_ sender: UIButton) {
        
        if(!buscarInput.hasText){
            showAlert(withTitle: "Error", withMessage: "Debe completar todos los campos")
            return
        }
        
        // 0: Load database
        let database = loadDatabase()
        
        // 1: Open database
        guard database.open() else {
            showAlert(withTitle: "Error Database", withMessage: "Error al abrir base de datos")
            return
        }
        
        do {
        
            // 2: Create SQL
            let query = "SELECT * FROM autos WHERE modelo like ?"
            
            // 3: Execute Query
            let rs = try database.executeQuery(query, values: ["%\(buscarInput.text!)%"])
            
            // 4: Iterate ResultSet
            while rs.next() == true {
                let modelo:String? = rs.string(forColumn: "modelo")
                let precio:Int32? = rs.int(forColumn: "precio")
                
                showAlert(withTitle: "Success", withMessage: "Auto [modelo:\(modelo!), precio:\(precio!)]")
            }
            
        } catch {
            showAlert(withTitle: "Error Query", withMessage: error.localizedDescription)
        }
        
        // 5: Close database
        database.close()
        
    }
    
    func showAlert(withTitle title:String, withMessage message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

