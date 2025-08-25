"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestGdsFeelStreamFormat,
	#superclass : #PackageManifest,
	#category : #'GdsFeel-StreamFormat-Manifest'
}

{ #category : #'code-critics' }
ManifestGdsFeelStreamFormat class >> ruleTransformationRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#GdsStreamLoopContext #requiredOrder #false)) #'2025-08-25T18:46:31.677102+09:00') )
]
