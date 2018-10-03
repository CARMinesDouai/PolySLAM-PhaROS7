"
VMTests

This class provides data that is used by the derived test classes.


"
Class {
	#name : #VMTests,
	#superclass : #TestCase,
	#instVars : [
		'showViewer',
		'faltruese'
	],
	#category : #'PolySLAM-Tests'
}

{ #category : #'testing support' }
VMTests >> ifVisualDebugDo: aBlock [
	showViewer ifTrue: aBlock 
]

{ #category : #running }
VMTests >> setUp [
	showViewer := true	
]
