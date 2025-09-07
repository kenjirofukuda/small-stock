Extension { #name : #ClassDefinitionPrinter }

{ #category : #'*KFCodeMange-Pharo' }
ClassDefinitionPrinter class >> for: aClass [

	"Given the current class definition syntax and the need for the class, 
	return the correct printer. 
	We only print slots with the fluid class definition."

	| instance |
	instance := (aClass needsSlotClassDefinition or: [ 
		             (self respondsTo: #showFluidClassDefinition) and: [ 
			             self perform: #showFluidClassDefinition ] ])
		            ifTrue: [ self fluid ]
		            ifFalse: [ self oldPharo ].
	Smalltalk
		at: #KFCodeManage
		ifPresent: [ :clazz | instance := clazz printer: instance ].
	^ instance
		  for: aClass;
		  yourself
]
