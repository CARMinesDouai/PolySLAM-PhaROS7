Class {
	#name : #PSMinJoinProbability,
	#superclass : #PSJoinProbability,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #probability }
PSMinJoinProbability >> probability [
(lineA nextLink = lineB) ifTrue:[^1].
	lineA chain = lineB chain ifTrue:[^ 0].
	(lineA value pointB inrangeOf: lineB value pointA) ifTrue: [ ^1 ].
	lamda := 5.
	^(((self colinearityOf: lineB value pointA with: lineA)
		min: (self colinearityOf: lineB value pointB with: lineA))
		min: (self colinearityOf: lineA value pointA with: lineB))
		min: (self colinearityOf: lineA value pointB with: lineB )
]
