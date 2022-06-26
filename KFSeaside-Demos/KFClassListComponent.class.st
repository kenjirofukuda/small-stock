"
TODO:

---- add groupby category tags ---
(RPackageOrganizer default packageOf: BlMorphicWorldMorph) classTags 
asArray sort: [ :a :b | a name <= b name ] .

"
Class {
	#name : #KFClassListComponent,
	#superclass : #KFBrowserComponent,
	#instVars : [
		'classes'
	],
	#category : #'KFSeaside-Demos'
}

{ #category : #accessing }
KFClassListComponent >> classes [
	^ classes
]

{ #category : #accessing }
KFClassListComponent >> classes: anObject [
	classes := anObject asArray
]

{ #category : #initialize }
KFClassListComponent >> initialize [
	super initialize.
	classes := #()
]

{ #category : #rendering }
KFClassListComponent >> renderContentOn: html [
	html div
		class: 'classList';
		with: [ html unorderedList
				with: [ self classes
						do: [ :cls | 
							html listItem
								class: 'wideMarginList';
								with: [ html anchor
										callback: [ self browser findUpdate: cls asString ];
										with: cls asString ] ] ] ]
]
