Extension { #name : #GdsElement }

{ #category : #'*GdsFeel-UI' }
GdsElement class >> drawerClass [
	^GdsElementDrawer
]

{ #category : #'*GdsFeel-UI' }
GdsElement >> drawerClass [
	^self class drawerClass
]
