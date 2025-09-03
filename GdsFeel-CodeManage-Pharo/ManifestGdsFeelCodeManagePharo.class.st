"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestGdsFeelCodeManagePharo,
	#superclass : #PackageManifest,
	#category : #'GdsFeel-CodeManage-Pharo-Manifest'
}

{ #category : #'code-critics' }
ManifestGdsFeelCodeManagePharo class >> ruleConsistencyCheckRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#'GdsCodeManage class' #postReadyForCuis #true)) #'2025-09-03T06:55:08.168873+09:00') #(#(#RGMethodDefinition #(#'GdsCodeManage class' #postReadyForSqueak #true)) #'2025-09-03T06:57:41.854145+09:00') )
]
