Extension { #name : #AbstractFileReference }

{ #category : #'*KFDxf-Model-Extension' }
AbstractFileReference >> asDxfFile [
	^ DxfFile new file: self
]
