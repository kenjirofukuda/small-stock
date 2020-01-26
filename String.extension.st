Extension { #name : #String }

{ #category : #'*GdsFeel-UI-Extension' }
String >> localizedGdsCaption [
	^GdsFeelMorphic localizedCaption: self.
]

{ #category : #'*GdsFeel-UI-Extension' }
String >> localizedGdsHelpText [
	^GdsFeelMorphic localizedHelpText: self.
]
