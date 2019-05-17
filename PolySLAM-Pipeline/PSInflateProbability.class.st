Class {
	#name : #PSInflateProbability,
	#superclass : #PSProbability,
	#instVars : [
		'inlier'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #initialization }
PSInflateProbability >> initialize [
	super initialize.
	inlier := 0.05. "5mm"
	
]

{ #category : #accessing }
PSInflateProbability >> inlier [
	^ inlier
]

{ #category : #accessing }
PSInflateProbability >> inlier: anObject [
	inlier := anObject
]
