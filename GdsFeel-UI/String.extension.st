Extension { #name : #String }

{ #category : #'*GdsFeel-UI' }
String >> localizedGdsCaption [
	^ GdsFeelMorphic localizedCaption: self
]

{ #category : #'*GdsFeel-UI' }
String >> localizedGdsHelpText [
	^ GdsFeelMorphic localizedHelpText: self
]
