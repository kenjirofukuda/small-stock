Class {
	#name : 'GdsIoReply',
	#superclass : 'GdsIoRecord',
	#category : 'GdsFeel-CLI-Service',
	#package : 'GdsFeel-CLI',
	#tag : 'Service'
}

{ #category : 'as yet unclassified' }
GdsIoReply class >> consume: aindex base64: aString [
	| reply |
	reply := self new.
	reply consume: aindex.
	reply base64: aString.
	^ reply
]

{ #category : 'as yet unclassified' }
GdsIoReply >> contents [
	| s |
	s := WriteStream on: (ByteArray new: self class bufferSize).
	self contentsOn: s.
	^ s contents
]

{ #category : 'as yet unclassified' }
GdsIoReply >> message: aString [
	self
		base64:
			(Base64MimeConverter mimeDecodeToBytes: (ReadStream on: aString))
				contents
]
