Class {
	#name : #GdsNotificationCenterTest,
	#superclass : #TestCase,
	#category : #'GdsFeel-Foundation-Tests'
}

{ #category : #tests }
GdsNotificationCenterTest >> testAddObserverSelectorNameObject [
	"Tests GdsNotificationCenter>>#addObserver:selector:name:object:"

	"Don't allow nil observer"
	self should: [
		GdsNotificationCenter defaultCenter
			addObserver: nil selector: nil name: nil object: nil
		] raise: Exception. 

	"Don't allow nil selector"
	self should: [
		GdsNotificationCenter defaultCenter
			addObserver: self selector: nil name: nil object: nil
		] raise: Exception. 	
]

{ #category : #tests }
GdsNotificationCenterTest >> testPostNotificationNameObject [
	"Tests GdsNotificationCenter>>#postNotificationName:object:"

	self should: [
		GdsNotificationCenter defaultCenter
			postNotificationName: nil object: nil 
		] raise: Exception 
]

{ #category : #tests }
GdsNotificationCenterTest >> testPostNotificationNameObjectUserInfo [
	"Tests GdsNotificationCenter>>#postNotificationName:object:userInfo:"

	"userInfo: only Dictionary"
	self should: [
		GdsNotificationCenter defaultCenter 
			postNotificationName: 'Boke' object: self userInfo: Array new. 
		] raise: Exception 
]
