//
//  AlertModel.swift
//  Image Feed
//
//  Created by Vladislav Mishukov on 05.11.2023.
//
import Foundation

struct AlertModel {
    //текст заголовка алерта
    let title: String
    //текст сообщения алерта
    let message: String
    //текст для кнопки алерта
    let buttonText: String
    //замыкание без параметров для действия по кнопке алерта
    var completion: () -> Void
}

