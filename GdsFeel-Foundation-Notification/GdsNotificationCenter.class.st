Class {
	#name : #GdsNotificationCenter,
	#superclass : #Object,
	#instVars : [
		'wildcard',
		'nameless',
		'named',
		'lock'
	],
	#classVars : [
		'DefaultCenter'
	],
	#category : #'GdsFeel-Foundation-Notification'
}

{ #category : #'as yet unclassified' }
GdsNotificationCenter class >> clearCenter [
	"self clearCenter"
	DefaultCenter := nil.
]

{ #category : #'as yet unclassified' }
GdsNotificationCenter class >> defaultCenter [
	DefaultCenter ifNil: [DefaultCenter := self new].
	^DefaultCenter
]

{ #category : #'as yet unclassified' }
GdsNotificationCenter class >> example [
	| nc |
	"self example"
	nc := GdsNotificationCenter defaultCenter.
	nc addObserver: Transcript 
		selector: #printString
		name: nil object: nil.

	nc addObserver: World 
		selector: #printString 
		name: 'NSWindowSizeDidChangeNotification' object: nil.

	nc addObserver: World 
		selector: #printString 
		name: 'NSWindowSizeWillChangeNotification' object: nil.

	nc addObserver: World 
		selector: #asString 
		name: nil object: Smalltalk.

	nc addObserver: World 
		selector: #asString 
		name: 'NSWindowSizeWillChangeNotification' object: Smalltalk.

	nc addObserver: Smalltalk 
		selector: #printString 
		name: 'NSWindowSizeWillChangeNotification' object: nil.

	nc explore
]

{ #category : #adding }
GdsNotificationCenter >> addObserver: anObserver selector: aSelector name: notificationName object: anObject [
	| o map  list2 |
	anObserver
		ifNil: [Exception signal: 'Nil observer passed to addObserver ...'].
	
	aSelector isEmptyOrNil  
		ifTrue: [Exception signal: 'Null selector passed to addObserver ...']. 
	
	(anObserver respondsTo: aSelector)
		ifFalse: [Exception signal: 'Observer can not handle specified selector'].
	
	self lock critical: [		
	o := GdsObservation new observer: anObserver; selector: aSelector.
	
	notificationName isEmptyOrNil
		ifFalse: [ "has name"
			map := named at: notificationName ifAbsentPut:[Dictionary new]. 
			(map at: anObject ifAbsentPut: [LinkedList new])
				ifNotNil: [:list |
					list addLast: o]]
		ifTrue: [
			anObject 
				ifNotNil: [
					list2 := nameless at: anObject ifAbsentPut:[LinkedList new]. 
					list2 addLast: o]
				ifNil: [
					wildcard addFirst: o]].]
]

{ #category : #'initialize-release' }
GdsNotificationCenter >> initialize [ 
	wildcard := LinkedList new.
	nameless := Dictionary new.
	named := Dictionary new.

]

{ #category : #private }
GdsNotificationCenter >> lock [
	^ lock ifNil: [ lock := Mutex new ]
]

{ #category : #private }
GdsNotificationCenter >> postAndRelease: aGdsNotification [
	| all object name |
	name := aGdsNotification name.
	name isEmptyOrNil
		ifTrue: [ Exception signal: 'Tried to post a notification with no name.' ].
	object := aGdsNotification object.
	all := OrderedCollection new.
	self lock
		critical: [ "Find all the observers that specified neither NAME nor OBJECT."
			all addAll: wildcard.

			"Find the observers that specified OBJECT, but didn't specify NAME"
			object
				ifNotNil: [ (nameless at: object ifAbsent: [  ])
						ifNotNil: [ :list | all addAll: list ] ].
			name
				ifNotNil: [ (named at: name ifAbsent: [  ])
						ifNotNil: [ :map | 
							(map at: object ifAbsent: [  ]) ifNotNil: [ :list | all addAll: list ].
							object
								ifNotNil:
									[ (map at: nil ifAbsent: [  ]) ifNotNil: [ :list | all addAll: list ] ] ] ] ].
	all reverse do: [ :o | o performWith: aGdsNotification ].
	^ all
]

{ #category : #'as yet unclassified' }
GdsNotificationCenter >> postNotification: aGdsNotification [
	aGdsNotification
		ifNil: [Exception signal: 'Tried to post a nil notification.'].
	self postAndRelease: aGdsNotification.
	
]

{ #category : #'as yet unclassified' }
GdsNotificationCenter >> postNotificationName: aName object: anObject [
	self postNotificationName: aName object: anObject userInfo: nil.
	
]

{ #category : #'as yet unclassified' }
GdsNotificationCenter >> postNotificationName: aName object: anObject userInfo: aDictionary [
	| n |
	n := GdsNotification new name: aName object: anObject userInfo: aDictionary.
	self postAndRelease: n.
	
]

{ #category : #removing }
GdsNotificationCenter >> removeObserver: anObserver [
	self removeObserver: anObserver name: nil object: nil.
	
]

{ #category : #removing }
GdsNotificationCenter >> removeObserver: anObserver name: notificationName object: anObject [
	|  observerRemoveBlock emptyListRemoveKeyBlock|
	(((notificationName isNil) and: [anObject isNil]) and: [anObserver isNil])
		ifTrue: [^self].

	observerRemoveBlock := [:list |
		list removeAllSuchThat: [:o | o observer == anObserver]].

	emptyListRemoveKeyBlock := [:map | 
		| colKeys |
		colKeys := OrderedCollection new.
		map keysAndValuesDo: [:key :list | list ifEmpty: [colKeys add: key]].
		colKeys do: [:key | map removeKey: key]].

	self lock critical: [
			
	((notificationName isNil) and: [anObject isNil])
		ifTrue: [
			observerRemoveBlock value: wildcard].

	notificationName isEmptyOrNil 
		ifTrue: [
			(nameless at: anObject ifAbsent:[]) 
				ifNotNil: [:list| 
					observerRemoveBlock value: list.
					list ifEmpty: [nameless removeKey: anObject]].
			named valuesDo: [:map | 
				(map valuesDo: [:list | 
					observerRemoveBlock value: list]).
				emptyListRemoveKeyBlock value: map].
			emptyListRemoveKeyBlock value: named]
		ifFalse: [
			(named at: notificationName ifAbsent:[])
				ifNotNil: [:map |
					(map at: anObject ifAbsent: [])
						ifNotNil: [:list3 | 
							observerRemoveBlock value: list3.].
					emptyListRemoveKeyBlock value: map].
			emptyListRemoveKeyBlock value: named]].
			
	Smalltalk garbageCollect.	
]
