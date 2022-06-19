Class {
	#name : #KFMethodViewListComponent,
	#superclass : #KFBrowserComponent,
	#instVars : [
		'compiledMethods',
		'methodViews',
		'showsSelector'
	],
	#category : #'KFSeaside-Demos'
}

{ #category : #hooks }
KFMethodViewListComponent >> children [
	^ self methodViews
]

{ #category : #accessing }
KFMethodViewListComponent >> compiledMethods [
	^ compiledMethods
]

{ #category : #accessing }
KFMethodViewListComponent >> compiledMethods: aCollection [
	self
		assert: (aCollection allSatisfy: [ :elm | elm isMemberOf: CompiledMethod ]).
	compiledMethods := aCollection.
	methodViews := nil
]

{ #category : #initialize }
KFMethodViewListComponent >> initialize [
	super initialize.
	compiledMethods := nil.
	methodViews := nil.
	showsSelector := true
]

{ #category : #accessing }
KFMethodViewListComponent >> methodViews [
	^ methodViews
		ifNil: [ methodViews := self compiledMethods
				collect: [ :cm | 
					KFMethodViewComponent new
						browser: self browser;
						compiledMethod: cm;
						showsSelector: self showsSelector;
						yourself ] ]
]

{ #category : #rendering }
KFMethodViewListComponent >> renderContentOn: aRenderer [
	self methodViews do: [ :view | aRenderer render: view ]
]

{ #category : #testing }
KFMethodViewListComponent >> showsSelector [
	^ showsSelector
]

{ #category : #accessing }
KFMethodViewListComponent >> showsSelector: anObject [
	showsSelector := anObject.
	self methodViews do: [ :view | view showsSelector: showsSelector ]
]
