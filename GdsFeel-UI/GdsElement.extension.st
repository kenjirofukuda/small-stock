Extension { #name : #GdsElement }

{ #category : #'*GdsFeel-UI-Extension' }
GdsElement >> drawerClass [
	^self class drawerClass
]

{ #category : #'*GdsFeel-UI-Extension' }
GdsElement class >> drawerClass [
	^GdsElementDrawer
]
