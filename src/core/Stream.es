/*
    Stream.es -- Stream interface.

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

module ejs {

    /** 
        Stream objects represent streams of data that pass data elements between an endpoint known as a source or sink 
        and a consumer or producer. Streams are full-duplex and may be stacked where intermediate streams are be used 
        as filters or data mutators. Example endpoints are the File, Socket, and Http classes. The TextStream is an 
        example of a filter stream. The data elements passed by streams may be any series of objects including: bytes, 
        lines of text, numbers or objects. Streams may buffer the incoming data or not. Streams may issue events to 
        registered observers for topics of interest. Streams may offer synchronous and asynchronous APIs. 
        @spec ejs
        @spec evolving
     */
    interface Stream {

        use default namespace public

        /** Read direction constant for $flush() */
        static const READ = 0x1

        /** Write direction constant for $flush() */
        static const WRITE = 0x2

        /** Both directions constant for $flush() */
        static const BOTH = 0x3

        /** 
            The current async mode. Set to true if the stream is in async mode.
         */
        function get async(): Boolean

        /** 
            Set the current sync/async mode. The async mode affects the blocking APIs: close, read and write.
            If in async mode, all Stream calls will not block. If observers have been registered, they can be used to
            respond to events to interface with the stream.
            @param enable If true, set the stream into async mode
         */
        function set async(enable: Boolean): Void

        /** 
            Close the stream. 
            @event close A close event is issued before closing the stream.
         */
        function close(): Void

        /**
            Flush the stream and underlying streams. A supplied flush $direction argument modifies the effect of this call.
            If direction is set to Stream.READ, then all read data is discarded. If direction is set to Stream.WRITE, 
            any buffered data is written. Stream.BOTH will cause both directions to be flushed. If the stream is in 
            sync mode, this call will block until all data is written. If the stream is in async mode, it will attempt 
            to write all data but will return immediately. Defaults to Stream.WRITE.
            @param dir direction to flush. Set to $READ, $WRITE or $BOTH.
         */
        function flush(dir: Number): Void 

        /** 
            Remove an observer from the stream. 
            @param name Event name previously used with observe. The name may be an array of events.
            @param observer Observer function previously used with observe.
         */
        function off(name, observer: Function): Void

        //  MOB - define what this is set to in the callback
        /** 
            Add an observer to the stream for the named events. 
            @param name :[String|Array] Name of the event to listen for. The name may be an array of events.
            @param observer Callback observer function. The function is called with the following signature:
                function observer(event: String, ...args): Void
            @event readable Issued when the stream becomes readable. 
            @event writable Issued when the stream becomes writable.
            @event close Issued when stream is being closed.
         */
        function on(name, observer: Function): Void

        /** 
            Read a data from the stream. 
            If data is available, the call will return immediately. 
            If no data is available and the stream is in sync mode, the call will block until data is available.
            If no data is available and the stream is in async mode, the call will not block and will return immediately.
            In this case a "readable" event will be issued when data is available for reading.
            @param buffer Destination byte array for read data.
            @param offset Offset in the byte array to place the data. If the offset is -1, then data is
                appended to the buffer write $position which is then updated. 
            @param count Read up to this number of bytes. If -1, read as much as the buffer will hold up. If the 
                stream is of fixed and known length (such as a file) and the buffer is of sufficient size or is growable, 
                read the entire stream. 
            @returns a count of the bytes actually read. Returns null on EOF.
            @event readable Issued when there is new read data available.
            @event writable Issued when the stream becomes empty.
         */
        function read(buffer: ByteArray, offset: Number = 0, count: Number = -1): Number 

        /** 
            Write data to the stream.
            If the stream can accept all the write data, the call returns immediately with the number of bytes written. 
            If writing more data than the stream can absorb in sync mode, the call will block until the data is written.
            If writing more data than the stream can absorb in async mode, the call will not block and will buffer the
            data and return immediately. Some streams will require a $flush() call to actually send the data.
            A "writable" event will be issued when the stream can again absorb more data.
            @param data Data to write. 
            @returns a count of the bytes actually written.
            @throws IOError if there is an I/O error.
            @event readable Issued when data is written and a consumer can read without blocking.
            @event writable Issued when the stream becomes empty and it is ready to be written to.
         */
        function write(...data): Number
    }
}


/*
    @copy   default
    
    Copyright (c) Embedthis Software LLC, 2003-2012. All Rights Reserved.
    Copyright (c) Michael O'Brien, 1993-2012. All Rights Reserved.
    
    This software is distributed under commercial and open source licenses.
    You may use the GPL open source license described below or you may acquire 
    a commercial license from Embedthis Software. You agree to be fully bound 
    by the terms of either license. Consult the LICENSE.TXT distributed with 
    this software for full details.
    
    This software is open source; you can redistribute it and/or modify it 
    under the terms of the GNU General Public License as published by the 
    Free Software Foundation; either version 2 of the License, or (at your 
    option) any later version. See the GNU General Public License for more 
    details at: http://www.embedthis.com/downloads/gplLicense.html
    
    This program is distributed WITHOUT ANY WARRANTY; without even the 
    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    
    This GPL license does NOT permit incorporating this software into 
    proprietary programs. If you are unable to comply with the GPL, you must
    acquire a commercial license to use this software. Commercial licenses 
    for this software and support services are available from Embedthis 
    Software at http://www.embedthis.com 
    
    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */
