import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSSpeechRecognizerDelegate
{
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength) // The status bar icon (remarkably simple to instantiate)
    let SR:NSSpeechRecognizer = NSSpeechRecognizer()! // The `!` operator gives the `NSSpeechRecognizer` instance if it exists, or nil if it doesn't exist.
                                                      // I've noticed that this class is the culprit for the weird audio quality drop.
    
    var siriLaunchCommands = ["Siri"]
    var customCommands = ["Execute"]
    
    // Has to be lazy in order to append the two instance members above.
    lazy var commands = siriLaunchCommands + customCommands

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Insert code here to initialize your application
        statusItem.title = "Hey Siri listener"
        if let button = statusItem.button
        {
            button.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage")) // References the image file in Assets.xcassets
//            button.action = Selector(("printQuote:"))
            
            let menu = NSMenu() // Attaches a dropdown to the status indicator
            
            menu.addItem(NSMenuItem(title: "Resume listening", action: #selector(AppDelegate.resumeListening), keyEquivalent: "r"))
            menu.addItem(NSMenuItem(title: "Stop listening", action: #selector(AppDelegate.stopListening), keyEquivalent: "s"))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit Hey Siri", action: #selector(AppDelegate.quit), keyEquivalent: "q"))
            
            statusItem.menu = menu
        }
        
        resumeListening()
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(AppDelegate.stopListening), name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(AppDelegate.resumeListening), name: NSWorkspace.didWakeNotification, object: nil)

    }
    
    @objc func quit()
    {
        NSApplication.shared.terminate(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }

    @objc func stopListening()
    {
        SR.stopListening()
        NSApplication.shared.resignFirstResponder()
    }
    
    @objc func resumeListening()
    {
        NSApplication.shared.becomeFirstResponder()

        SR.commands = commands
        SR.delegate = self
        SR.listensInForegroundOnly = false

        SR.startListening(); print("listening")
    }
    
    // The callback for when a new command is recognized by the speech recognizer.
    func speechRecognizer(_ sender: NSSpeechRecognizer, didRecognizeCommand command: String)
    {
        print("Got new command: " + command)
        
        if siriLaunchCommands.contains(command)
        {
            NSWorkspace.shared.launchApplication("/Applications/Siri.app")
        }
    }

}

