//
//  FileMonitor.swift
//  FileMonitor
//
//  Created by scchn on 2020/5/18.
//  Copyright © 2020 scchn. All rights reserved.
//

import Foundation

// The application creates a stream by calling FSEventStreamCreate or FSEventStreamCreateRelativeToDevice.
// The application schedules the stream on the run loop by calling FSEventStreamScheduleWithRunLoop.
// The application tells the file system events daemon to start sending events by calling FSEventStreamStart.
// The application services events as they arrive. The API posts events by calling the callback function specified in step 1.
// The application tells the daemon to stop sending events by calling FSEventStreamStop.

// If the application needs to restart the stream, go to step 3.

// The application unschedules the event from its run loop by calling FSEventStreamUnscheduleFromRunLoop.
// The application invalidates the stream by calling FSEventStreamInvalidate.
// The application releases its reference to the stream by calling FSEventStreamRelease.
// These steps are explained in more detail in the sections that follow.

public let FileMonitorEventsKey = "com.scchn.FileMonitor.FileMonitorEventsKey"

extension Notification.Name {
    
    /// Read the coalesced events that is of type `[FileMonitor.CoalescedEvent]` using the key `FileMonitorEventsKey` in `userInfo`
    public static let fileMonitorDidReceiveEvent =
        Notification.Name("com.scchn.FileMonitor.fileMonitorDidReceiveEvent")
    
}

fileprivate func callback(stream: ConstFSEventStreamRef,
                          callbackInfo: UnsafeMutableRawPointer?,
                          numEvents: Int,
                          eventPaths: UnsafeMutableRawPointer,
                          eventFlags: UnsafePointer<FSEventStreamEventFlags>,
                          eventIds: UnsafePointer<FSEventStreamEventId>) -> Void
{
    guard let info = callbackInfo else { return }

    let monitor = Unmanaged<FileMonitor>.fromOpaque(info)
        .takeUnretainedValue()
    let paths = Unmanaged<NSArray>.fromOpaque(eventPaths)
        .takeUnretainedValue()
        .map { $0 as! String }
    let events: [FileMonitor.Event] = (0..<numEvents).map { i in
        FileMonitor.Event(
            path: paths[i],
            flags: FileMonitor.EventFlags(rawValue: eventFlags[i]),
            id: FileMonitor.EventId.id(eventIds[i])
        )
    }
    
    DispatchQueue.main.async {
        monitor.eventHandler?(events)
        
        NotificationCenter.default.post(
            name: .fileMonitorDidReceiveEvent,
            object: monitor,
            userInfo: [FileMonitorEventsKey: events]
        )
    }
}

extension FileMonitor {
    
    public enum `Type` {
        case host
        case disk(dev_t)
    }
    
    public enum EventId {
        case sinceNow
        case id(FSEventStreamEventId)
    }
    
    public struct Event {
        public var path: String
        public var flags: EventFlags
        public var id: EventId
    }
    
    public typealias CoalescedEvent = [Event]
    
    public typealias EventHandler = (CoalescedEvent) -> Void
    
}

public final class FileMonitor {
    
    private var stream: FSEventStreamRef!
    
    public let paths: [String]
    public private(set) var isMonitoring = false
    public private(set) var isValid = true
    public var eventHandler: EventHandler?
    
    private func fsEventId(_ eventId: EventId) -> FSEventStreamEventId {
        guard case .id(let id) = eventId else {
            return FSEventStreamEventId(kFSEventStreamEventIdSinceNow)
        }
        return id
    }
    
    public init(
        paths: [String],
        type: Type = .host,
        flags: CreateFlags,
        latency: TimeInterval,
        eventId: EventId = .sinceNow
    ) {
        self.paths = paths
        
        let cfPaths     = (paths as CFArray)
        let createFlags = flags.union(.useCFTypes)
        let eventId     = fsEventId(eventId)
        var ctx         = FSEventStreamContext()
        
        ctx.info = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        
        switch type {
        case .host:
            stream = FSEventStreamCreate(
                nil, callback, &ctx,
                cfPaths, eventId, latency, createFlags.rawValue
            )!
        case .disk(let dev):
            stream = FSEventStreamCreateRelativeToDevice(
                nil, callback, &ctx,
                dev, cfPaths, eventId, latency, createFlags.rawValue
            )!
        }
        
        FSEventStreamScheduleWithRunLoop(
            stream, CFRunLoopGetMain(),
            CFRunLoopMode.defaultMode.rawValue
        )
    }
    
    deinit {
        invalidate()
    }
    
    /**
     Attempts to register with the events service to receive events per the parameters in the monitor.
     
     Once started, the monitor can be stopped via `stop()`.
     */
    public func start() {
        guard isValid && !isMonitoring else { return }
        isMonitoring = true
        FSEventStreamStart(stream)
    }
    
    /**
     Unregisters with the events service.
     `stop()` can only be called if the monitor has been started.
     
     Once stopped, the stream can be restarted via `start()`,
     at which point it will resume receiving events from where it left off.
     */
    public func stop() {
        guard isValid && isMonitoring else { return }
        isMonitoring = false
        FSEventStreamStop(stream)
    }
    
    public enum FlushMode {
        case sync
        case async
    }
    
    /// `flush(mode:)` can only be called after the monitor has been started.
    public func flush(mode: FlushMode) {
        guard isValid && isMonitoring else { return }
        switch mode {
        case .sync:  FSEventStreamFlushSync(stream)
        case .async: FSEventStreamFlushAsync(stream)
        }
    }
    
    /// Invalidates the monitor.
    public func invalidate() {
        guard isValid else { return }
        stop()
        FSEventStreamUnscheduleFromRunLoop(
            stream, CFRunLoopGetMain(),
            CFRunLoopMode.defaultMode.rawValue
        )
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        isValid = false
    }
    
}
