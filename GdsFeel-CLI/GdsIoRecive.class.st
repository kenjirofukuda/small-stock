Class {
	#name : #GdsIoRecive,
	#superclass : #GdsIoRecord,
	#category : #'GdsFeel-CLI-Service'
}

{ #category : #'as yet unclassified' }
GdsIoRecive >> asString [
	^ GdsServer
		chomp:
			(Base64MimeConverter mimeDecodeToChars: (ReadStream on: base64))
				contents
]

{ #category : #'as yet unclassified' }
GdsIoRecive >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream print: self asString.
	aStream nextPut: $)
]
