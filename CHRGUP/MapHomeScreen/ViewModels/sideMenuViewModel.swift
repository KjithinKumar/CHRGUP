//
//  sideMenuViewModel.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 11/03/25.
//

import Foundation

struct SideMenuItem {
    let title: String
    let icon: String
    let sideMenuDestiantion : sideMenuDestination
}
enum sideMenuDestination{
    case mygarage
    case favouritedocks
    case history
    case helpandsupport
    case settings
    
}

protocol SideMenuViewModelProtocolInterface {
    var sideMenuItems: [SideMenuItem] { get }
    
}

struct SideMenuViewModel: SideMenuViewModelProtocolInterface {
    let sideMenuItems = [
        SideMenuItem(title: AppStrings.leftMenu.menuItem1, icon: AppStrings.leftMenu.menuItemImage1,sideMenuDestiantion: .mygarage),
        SideMenuItem(title: AppStrings.leftMenu.menuItem2, icon: AppStrings.leftMenu.menuItemImage2,sideMenuDestiantion: .favouritedocks),
        SideMenuItem(title: AppStrings.leftMenu.menuItem3, icon: AppStrings.leftMenu.menuItemImage3,sideMenuDestiantion: .history),
        SideMenuItem(title: AppStrings.leftMenu.menuItem4, icon: AppStrings.leftMenu.menuItemImage4,sideMenuDestiantion: .helpandsupport),
        SideMenuItem(title: AppStrings.leftMenu.menuItem5, icon: AppStrings.leftMenu.menuItemImage5,sideMenuDestiantion: .settings),
    ]
}
