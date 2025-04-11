Extension { #name : 'PPParser' }

{ #category : '*GplPetitParser' }
PPParser >> gplPPToken [
	^ GplPPTokenParser on: self
]
