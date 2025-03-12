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
}

protocol SideMenuViewModelProtocolInterface {
    var sideMenuItems: [SideMenuItem] { get }
    
}

struct SideMenuViewModel: SideMenuViewModelProtocolInterface {
    let sideMenuItems = [
        SideMenuItem(title: AppStrings.leftMenu.menuItem1, icon: AppStrings.leftMenu.menuItemImage1),
        SideMenuItem(title: AppStrings.leftMenu.menuItem2, icon: AppStrings.leftMenu.menuItemImage2),
        SideMenuItem(title: AppStrings.leftMenu.menuItem3, icon: AppStrings.leftMenu.menuItemImage3),
        SideMenuItem(title: AppStrings.leftMenu.menuItem4, icon: AppStrings.leftMenu.menuItemImage4),
        SideMenuItem(title: AppStrings.leftMenu.menuItem5, icon: AppStrings.leftMenu.menuItemImage5),
    ]
}
