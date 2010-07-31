/**
    uploadedFile.es - Description of an uploaded file. Instances are created and stored in Request.files.
 */

module ejs.web {

    /** 
        Upload file class. Instances of UploadFile are created for each uploaded file when POST requests using
        multi-part mime body content are received. The UploadFile instances are stored in the request.files property.
        Users should not create instances of UploadFile manually.
        @spec ejs
        @stability evolving
     */
    class UploadFile {

        use default namespace public

        /** 
            Name of the uploaded file given by the client
         */
        native var clientFilename: String

        /** 
            Mime type of the encoded data
         */
        native var contentType: String

        /** 
            Name of the uploaded file. This is a temporary file in the upload directory.
         */
        native var filename: String

        /** 
            HTML input ID for the upload file element
         */
        var name: String
 
        /** 
            Size of the uploaded file in bytes
         */
        native var size: Number
    }
}

