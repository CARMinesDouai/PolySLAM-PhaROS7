Class {
	#name : #PSInflateLinkingProbability,
	#superclass : #PSInflateProbability,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #probability }
PSInflateLinkingProbability >> probability [
	(lineA value pointB dist: (lineB value pointA)) <= inlier
		ifTrue: [ ^ 1 ]
		ifFalse: [ ^0 ]
]
