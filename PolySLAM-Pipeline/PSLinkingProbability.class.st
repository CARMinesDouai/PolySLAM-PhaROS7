Class {
	#name : #PSLinkingProbability,
	#superclass : #PSColinearProbability,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSLinkingProbability class >> from: lineA and: lineB [
	^ self new lineA: lineA; lineB: lineB; yourself.
]

{ #category : #probability }
PSLinkingProbability >> probability [
	"|vertices v1 v2"
	"alway linking if the two lines are adjance"
	(lineA nextLink = lineB) ifTrue:[^1].
	lineA chain = lineB chain ifTrue:[^ 0].
	(lineA value pointB inrangeOf: lineB value pointA) ifTrue: [ ^1 ].
	"otherwise, select the two nerest endpoints"
	"vertices := self nearestVertices."
	"v1 := vertices first.
	v2 := vertices second.
	(v1 inrangeOf: v2) ifTrue:[
		^ 0
	]."
	"not in the same direction"
	^self colinearity 
]
