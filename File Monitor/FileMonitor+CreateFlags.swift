//
//  FileMonitor+CreateFlags.swift
//  FileMonitor
//
//  Created by scchn on 2020/5/18.
//  Copyright © 2020 scchn. All rights reserved.
//

extension FileMonitor {
    
    public struct CreateFlags: OptionSet {
        public var rawValue: FSEventStreamCreateFlags
        
        private init(rawValue: Int) {
            self.rawValue = FSEventStreamCreateFlags(rawValue)
        }
        
        public init(rawValue: FSEventStreamCreateFlags) {
            self.rawValue = rawValue
        }
        
        static let useCFTypes = CreateFlags(rawValue: kFSEventStreamCreateFlagUseCFTypes)
        
        public static let none = CreateFlags(rawValue: kFSEventStreamCreateFlagNone)
        
        /**
         noDefer
         
         Affects the meaning of the latency parameter. If you specify this flag and more than latency seconds have elapsed since the last event, your app will receive the event immediately. The delivery of the event resets the latency timer and any further events will be delivered after latency seconds have elapsed. This flag is useful for apps that are interactive and want to react immediately to changes but avoid getting swamped by notifications when changes are occurringin rapid succession. If you do not specify this flag, then when an event occurs after a period of no events, the latency timer is started. Any events that occur during the next latency seconds will be delivered as one group (including that first event). The delivery of the group of events resets the latency timer and any further events will be delivered after latency seconds. This is the default behavior and is more appropriate for background, daemon or batch processing apps.
         */
        public static let noDefer = CreateFlags(rawValue: kFSEventStreamCreateFlagNoDefer)
        
        /**
         watchRoot
         
         Request notifications of changes along the path to the path(s) you're watching. For example, with this flag, if you watch "/foo/bar" and it is renamed to "/foo/bar.old", you would receive a RootChanged event. The same is true if the directory "/foo" were renamed. The event you receive is a special event: the path for the event is the original path you specified, the flag kFSEventStreamEventFlagRootChanged is set and event ID is zero. RootChanged events are useful to indicate that you should rescan a particular hierarchy because it changed completely (as opposed to the things inside of it changing). If you want to track the current location of a directory, it is best to open the directory before creating the stream so that you have a file descriptor for it and can issue an F_GETPATH fcntl() to find the current path.
         */
        public static let watchRoot = CreateFlags(rawValue: kFSEventStreamCreateFlagWatchRoot)
        
        /**
         ignoreSelf
         
         Don't send events that were triggered by the current process. This is useful for reducing the volume of events that are sent. It is only useful if your process might modify the file system hierarchy beneath the path(s) being monitored. Note: this has no effect on historical events, i.e., those delivered before the HistoryDone sentinel event.
         */
        public static let ignoreSelf = CreateFlags(rawValue: kFSEventStreamCreateFlagIgnoreSelf)
        
        /**
         fileEvents
         
         Request file-level notifications. Your stream will receive events about individual files in the hierarchy you're watching instead of only receiving directory level notifications. Use this flag with care as it will generate significantly more events than without it.
         */
        public static let fileEvents = CreateFlags(rawValue: kFSEventStreamCreateFlagFileEvents)
        
        public static let markSelf = CreateFlags(rawValue: kFSEventStreamCreateFlagMarkSelf)
        
        @available(OSX 10.13, *)
        public static let useExtendedData = CreateFlags(rawValue: kFSEventStreamCreateFlagUseExtendedData)
    }
    
}
