private
lookupTypeCodeMap

	| map |
	map := Dictionary new.
	self headerSpec do: [ :each | map at: each first put: each second ].
	^ map