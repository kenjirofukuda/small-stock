private
allCreatableClasses

	"self allCreatableClasses inspect."

	^ self allSubclasses reject: [ :clazz | clazz type = #none ]