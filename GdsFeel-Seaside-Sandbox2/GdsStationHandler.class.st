Class {
	#name : #GdsStationHandler,
	#superclass : #WARestfulHandler,
	#category : #'GdsFeel-Seaside-Sandbox2'
}

{ #category : #'class initialization' }
GdsStationHandler class >> initialize [
	WAAdmin register: self at: 'gds-api'
]

{ #category : #'as yet unclassified' }
GdsStationHandler >> activeLibrary [
	<get>
	<path: '/activeLibrary'>
	<produces: 'application/json'>
	^ (GdsStation default library
		ifNil: [ '' ]
		ifNotNil: [ :lib | lib libName ]) asJson
]

{ #category : #accessing }
GdsStationHandler >> elements [
	<get>
	<path: '/elements'>
	<produces: 'application/json'>
	^ (GdsStation default structure
		ifNil: [ #() ]
		ifNotNil: [ :s | s elements ]) asJson
]

{ #category : #accessing }
GdsStationHandler >> libraryNames [
	<get>
	<path: '/libraryNames'>
	<produces: 'application/json'>
	^ GdsStation default libraryNames asJson
]

{ #category : #accessing }
GdsStationHandler >> status [
	<get>
	<path: '/status'>
	<produces: 'application/json'>
	^ '{"status": "dead"}'
]

{ #category : #accessing }
GdsStationHandler >> structureName [
	<get>
	<path: '/structureName'>
	<produces: 'application/json'>
	^ (GdsStation default structure
		ifNil: [ '' ]
		ifNotNil: [ :s | s name ]) asJson
]

{ #category : #'structure control' }
GdsStationHandler >> structureNames [
	<get>
	<path: '/structureNames'>
	<produces: 'application/json'>
	^ (GdsStation default library
		ifNil: [ #() ]
		ifNotNil: [ :lib | lib structureNames ]) asJson
]

{ #category : #accessing }
GdsStationHandler >> structures [
	<get>
	<path: '/structures'>
	<produces: 'application/json'>
	^ (GdsStation default library
		ifNil: [ #() ]
		ifNotNil: [ :lib | lib structures ]) asJson
]
