Extension { #name : #DxfDataGroups }

{ #category : #'*GdsFeel-Model-ElementAddition' }
DxfDataGroups >> printDxfOn: aStream [
	self dataGroups ifNotNil: [ :groups | groups do: [ :each | each printDxfOn: aStream ] ]
]
