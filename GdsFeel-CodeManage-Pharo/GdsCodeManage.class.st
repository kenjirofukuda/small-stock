"
abstract class for GdsCodeManageForSqueak and GdsCodeManageForCuis

"
Class {
	#name : #GdsCodeManage,
	#superclass : #Object,
	#instVars : [
		'beLegacyPrinter',
		'originalPrinter'
	],
	#classVars : [
		'Default'
	],
	#category : #'GdsFeel-CodeManage-Pharo'
}

{ #category : #'see class side' }
GdsCodeManage class >> default [ 
	^ Default ifNil: [ Default := self new ]
]

{ #category : #'see class side' }
GdsCodeManage class >> for: aClass [
	^ self default for: aClass
]

{ #category : #'registry access' }
GdsCodeManage class >> initialize [
	Default := nil.
]

{ #category : #'see class side' }
GdsCodeManage class >> printer: aClassDifinitionPrinter [
	^ self default printer: aClassDifinitionPrinter
]

{ #category : #'registry access' }
GdsCodeManage class >> workspace [
'



'.
]

{ #category : #testing }
GdsCodeManage >> canLegacyPrinter [
	^ beLegacyPrinter
	
]

{ #category : #testing }
GdsCodeManage >> fileOutTargets [
	<example>
	"self default fileOutTargets"

	self legacyPrinterActivateDuring: [ 
		self targetPackageNames do: [ :pkgSymbol | 
			| pkg |
			pkg := RPackageOrganizer default packageNamed: pkgSymbol.
			pkg fileOut ] ]
]

{ #category : #'instance creation' }
GdsCodeManage >> for: aClass [

]

{ #category : #initialization }
GdsCodeManage >> initialize [
	beLegacyPrinter := false
]

{ #category : #testing }
GdsCodeManage >> legacyPrinterActivateDuring: aBlock [

	beLegacyPrinter := true.
	[ aBlock value ] ensure: [ beLegacyPrinter := false ]
]

{ #category : #initialization }
GdsCodeManage >> printer: aClassDefinitionPrinter [

	^ beLegacyPrinter
		  ifTrue: [ ClassDefinitionPrinter legacy ]
		  ifFalse: [ aClassDefinitionPrinter ]
]

{ #category : #'see class side' }
GdsCodeManage >> seeClassSide [
]

{ #category : #testing }
GdsCodeManage >> targetPackageNames [
	"GdsCodeManage default targetPackageNames"
	| col |
	col := OrderedCollection new.
	col addAll:
		(RPackageOrganizer default packageNames select: [ :pkg | 
			 pkg beginsWithAnyOf: #( 'GdsFeel-StreamFormat-Atomic' ) ]).
	^ col
]
