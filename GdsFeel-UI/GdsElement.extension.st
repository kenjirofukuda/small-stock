Extension { #name : #GdsElement }

{ #category : #'*GdsFeel-UI' }
GdsElement classSide >> drawerClass [
	^GdsElementDrawer
]

{ #category : #'*GdsFeel-UI' }
GdsElement >> drawerClass [
	^self class drawerClass
]
