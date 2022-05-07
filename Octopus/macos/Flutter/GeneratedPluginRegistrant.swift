//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import desktop_context_menu_macos
import desktop_drop
import pasteboard
import path_provider_macos
import screen_capturer
import shared_preferences_macos
import system_tray
import url_launcher_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  DesktopContextMenuMacosPlugin.register(with: registry.registrar(forPlugin: "DesktopContextMenuMacosPlugin"))
  DesktopDropPlugin.register(with: registry.registrar(forPlugin: "DesktopDropPlugin"))
  PasteboardPlugin.register(with: registry.registrar(forPlugin: "PasteboardPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  ScreenCapturerPlugin.register(with: registry.registrar(forPlugin: "ScreenCapturerPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SystemTrayPlugin.register(with: registry.registrar(forPlugin: "SystemTrayPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
}
