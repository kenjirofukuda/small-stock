Extension { #name : 'ClassDefinitionPrinter' }

{ #category : '*KFCodeManage-Pharo' }
ClassDefinitionPrinter class >> for: aClass [

	"Given the current class definition syntax and the need for the class, 
	return the correct printer. 
	We only print slots with the fluid class definition."

	| instance |
	instance := self fluid.
	(self respondsTo: #showFluidClassDefinition)
		ifTrue: [ 
			(self perform: #showFluidClassDefinition)
				ifFalse: [ self oldPharo ] ].
	Smalltalk
		at: #KFCodeManage
		ifPresent: [ :clazz | instance := clazz printer: instance ].
	^ instance
		  for: aClass;
		  yourself
]
