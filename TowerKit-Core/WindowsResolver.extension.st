Extension { #name : #WindowsResolver }

{ #category : #'*TowerKit-Core' }
WindowsResolver >> documents [
	| f |
	f := self home / 'My Documents'.
	^ f isDirectory ifTrue: [ f ] ifFalse: [ self home / 'Documents' ]
]
