api
nextRecord

	"^[GdsStreamRecord new bytes: self nextByteArray] on: Error do: [:ex | nil]."

	| bytes |
	bytes := self nextByteArray.
	bytes ifEmpty: [ ^ nil ].
	^ GdsStreamRecord new bytes: bytes