//
//  FileMonitor+EventFlags.swift
//  FileMonitor
//
//  Created by scchn on 2020/5/18.
//  Copyright © 2020 scchn. All rights reserved.
//

extension FileMonitor {
    
    public struct EventFlags: OptionSet {
        
        public var rawValue: FSEventStreamEventFlags
        
        private init(rawValue: Int) {
            self.rawValue = FSEventStreamEventFlags(rawValue)
        }
        
        public init(rawValue: FSEventStreamEventFlags) {
            self.rawValue = rawValue
        }

        /**
         none
         
         There was some change in the directory at the specific path
         supplied in this event.
         */
        public static let none = EventFlags(rawValue: kFSEventStreamEventFlagNone)
        
        /**
         mustScanSubDirs

         Your application must rescan not just the directory given in the
         event, but all its children, recursively. This can happen if there
         was a problem whereby events were coalesced hierarchically. For
         example, an event in /Users/jsmith/Music and an event in
         /Users/jsmith/Pictures might be coalesced into an event with this
         flag set and path=/Users/jsmith. If this flag is set you may be
         able to get an idea of whether the bottleneck happened in the
         kernel (less likely) or in your client (more likely) by checking
         for the presence of the informational flags
         kFSEventStreamEventFlagUserDropped or
         kFSEventStreamEventFlagKernelDropped.
         */
        public static let mustScanSubDirs = EventFlags(rawValue: kFSEventStreamEventFlagMustScanSubDirs)
        
        /**
         userDropped
         
         The kFSEventStreamEventFlagUserDropped or
         kFSEventStreamEventFlagKernelDropped flags may be set in addition
         to the kFSEventStreamEventFlagMustScanSubDirs flag to indicate
         that a problem occurred in buffering the events (the particular
         flag set indicates where the problem occurred) and that the client
         must do a full scan of any directories (and their subdirectories,
         recursively) being monitored by this stream. If you asked to
         monitor multiple paths with this stream then you will be notified
         about all of them. Your code need only check for the
         kFSEventStreamEventFlagMustScanSubDirs flag; these flags (if
         present) only provide information to help you diagnose the problem.
         */
        public static let userDropped = EventFlags(rawValue: kFSEventStreamEventFlagUserDropped)
        
        public static let kernelDropped = EventFlags(rawValue: kFSEventStreamEventFlagKernelDropped)
        
        /**
         eventIdsWrapped
         
         If kFSEventStreamEventFlagEventIdsWrapped is set, it means the
         64-bit event ID counter wrapped around. As a result,
         previously-issued event ID's are no longer valid arguments for the
         sinceWhen parameter of the FSEventStreamCreate...() functions.
         */
        public static let eventIdsWrapped = EventFlags(rawValue: kFSEventStreamEventFlagEventIdsWrapped)
        
        /**
         historyDone
         
         Denotes a sentinel event sent to mark the end of the "historical"
         events sent as a result of specifying a sinceWhen value in the
         FSEventStreamCreate...() call that created this event stream. (It
         will not be sent if kFSEventStreamEventIdSinceNow was passed for
         sinceWhen.) After invoking the client's callback with all the
         "historical" events that occurred before now, the client's
         callback will be invoked with an event where the
         kFSEventStreamEventFlagHistoryDone flag is set. The client should
         ignore the path supplied in this callback.
         */
        public static let historyDone = EventFlags(rawValue: kFSEventStreamEventFlagHistoryDone)
        
        /**
         rootChanged

         Denotes a special event sent when there is a change to one of the
         directories along the path to one of the directories you asked to
         watch. When this flag is set, the event ID is zero and the path
         corresponds to one of the paths you asked to watch (specifically,
         the one that changed). The path may no longer exist because it or
         one of its parents was deleted or renamed. Events with this flag
         set will only be sent if you passed the flag
         kFSEventStreamCreateFlagWatchRoot to FSEventStreamCreate...() when
         you created the stream.
         */
        public static let rootChanged = EventFlags(rawValue: kFSEventStreamEventFlagRootChanged)
        
        /**
         mount

         Denotes a special event sent when a volume is mounted underneath
         one of the paths being monitored. The path in the event is the
         path to the newly-mounted volume. You will receive one of these
         notifications for every volume mount event inside the kernel
         (independent of DiskArbitration). Beware that a newly-mounted
         volume could contain an arbitrarily large directory hierarchy.
         Avoid pitfalls like triggering a recursive scan of a non-local
         filesystem, which you can detect by checking for the absence of
         the MNT_LOCAL flag in the f_flags returned by statfs(). Also be
         aware of the MNT_DONTBROWSE flag that is set for volumes which
         should not be displayed by user interface elements.
         */
        public static let mount = EventFlags(rawValue: kFSEventStreamEventFlagMount)
        
        /**
         unmount

         Denotes a special event sent when a volume is unmounted underneath
         one of the paths being monitored. The path in the event is the
         path to the directory from which the volume was unmounted. You
         will receive one of these notifications for every volume unmount
         event inside the kernel. This is not a substitute for the
         notifications provided by the DiskArbitration framework; you only
         get notified after the unmount has occurred. Beware that
         unmounting a volume could uncover an arbitrarily large directory
         hierarchy, although Mac OS X never does that.
         */
        public static let unmount = EventFlags(rawValue: kFSEventStreamEventFlagUnmount)
        
        /**
         itemCreated

         A file system object was created at the specific path supplied in this event.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemCreated = EventFlags(rawValue: kFSEventStreamEventFlagItemCreated)
        
        /**
         itemRemoved

         A file system object was removed at the specific path supplied in this event.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemRemoved = EventFlags(rawValue: kFSEventStreamEventFlagItemRemoved)
        
        /**
         itemInodeMetaMod

         A file system object at the specific path supplied in this event had its metadata modified.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemInodeMetaMod = EventFlags(rawValue: kFSEventStreamEventFlagItemInodeMetaMod)
        
        /**
         itemRenamed

         A file system object was renamed at the specific path supplied in this event.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemRenamed = EventFlags(rawValue: kFSEventStreamEventFlagItemRenamed)
        
        /**
         itemModified

         A file system object at the specific path supplied in this event had its data modified.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemModified = EventFlags(rawValue: kFSEventStreamEventFlagItemModified)
        
        /**
         itemFinderInfoMod

         A file system object at the specific path supplied in this event had its FinderInfo data modified.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemFinderInfoMod = EventFlags(rawValue: kFSEventStreamEventFlagItemFinderInfoMod)
        
        /**
         itemChangeOwner

         A file system object at the specific path supplied in this event had its ownership changed.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemChangeOwner = EventFlags(rawValue: kFSEventStreamEventFlagItemChangeOwner)
        
        /**
         itemXattrMod

         A file system object at the specific path supplied in this event had its extended attributes modified.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemXattrMod = EventFlags(rawValue: kFSEventStreamEventFlagItemXattrMod)
        
        /**
         itemIsFile

         The file system object at the specific path supplied in this event is a regular file.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemIsFile = EventFlags(rawValue: kFSEventStreamEventFlagItemIsFile)
        
        /**
         itemIsDir

         The file system object at the specific path supplied in this event is a directory.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemIsDir = EventFlags(rawValue: kFSEventStreamEventFlagItemIsDir)
        
        /**
         itemIsSymlink

         The file system object at the specific path supplied in this event is a symbolic link.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemIsSymlink = EventFlags(rawValue: kFSEventStreamEventFlagItemIsSymlink)
        
        /**
         ownEvent

         Indicates the event was triggered by the current process.
         (This flag is only ever set if you specified the MarkSelf flag when creating the stream.)
         */
        public static let ownEvent = EventFlags(rawValue: kFSEventStreamEventFlagOwnEvent)
        
        /**
         itemIsHardlink

         Indicates the object at the specified path supplied in this event is a hard link.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemIsHardlink = EventFlags(rawValue: kFSEventStreamEventFlagItemIsHardlink)
        
        /**
         itemIsLastHardlink

         Indicates the object at the specific path supplied in this event was the last hard link.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemIsLastHardlink = EventFlags(rawValue: kFSEventStreamEventFlagItemIsLastHardlink)
        
        /**
         itemCloned

         The file system object at the specific path supplied in this event is a clone or was cloned.
         (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        @available(OSX 10.13, *)
        public static let itemCloned = EventFlags(rawValue: kFSEventStreamEventFlagItemCloned)
    }
    
}

#if DEBUG
extension FileMonitor.EventFlags: CustomStringConvertible {

    public var description: String {
        var descs = [String]()
        
        if contains(.mustScanSubDirs)   { descs.append(".mustScanSubDirs") }
        if contains(.userDropped)       { descs.append(".userDropped") }
        if contains(.kernelDropped)     { descs.append(".kernelDropped") }
        if contains(.eventIdsWrapped)   { descs.append(".eventIdsWrapped") }
        if contains(.historyDone)       { descs.append(".historyDone") }
        if contains(.rootChanged)       { descs.append(".rootChanged") }
        if contains(.mount)             { descs.append(".mount") }
        if contains(.unmount)           { descs.append(".unmount") }
        if contains(.itemCreated)       { descs.append(".itemCreated") }
        if contains(.itemRemoved)       { descs.append(".itemRemoved") }
        if contains(.itemInodeMetaMod)  { descs.append(".itemInodeMetaMod") }
        if contains(.itemRenamed)       { descs.append(".itemRenamed") }
        if contains(.itemModified)      { descs.append(".itemModified") }
        if contains(.itemFinderInfoMod) { descs.append(".itemFinderInfoMod") }
        if contains(.itemChangeOwner)   { descs.append(".itemChangeOwner") }
        if contains(.itemXattrMod)      { descs.append(".itemXattrMod") }
        if contains(.itemIsFile)        { descs.append(".itemIsFile") }
        if contains(.itemIsDir)         { descs.append(".itemIsDir") }
        if contains(.itemIsSymlink)     { descs.append(".itemIsSymlink") }
        if contains(.ownEvent)          { descs.append(".ownEvent") }
        if contains(.itemIsHardlink)    { descs.append(".itemIsHardlink") }
        if contains(.itemIsLastHardlink){ descs.append(".itemIsLastHardlink") }
        
        if #available(OSX 10.13, *) {
            if contains(.itemCloned) { descs.append("itemCloned") }
        }
        
        return "[\(descs.joined(separator: ", "))]"
    }
    
}
#endif

