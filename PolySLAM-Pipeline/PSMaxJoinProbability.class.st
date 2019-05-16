Class {
	#name : #PSMaxJoinProbability,
	#superclass : #PSJoinProbability,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #probability }
PSMaxJoinProbability >> probability [
	(lineA nextLink = lineB) ifTrue:[^1].
	lineA chain = lineB chain ifTrue:[^ 0].
	(lineA value pointB inrangeOf: lineB value pointA) ifTrue: [ ^1 ].
	lamda := 5.
	^(((self colinearityOf: lineB value pointA with: lineA)
		max: (self colinearityOf: lineB value pointB with: lineA))
		max: (self colinearityOf: lineA value pointA with: lineB))
		max: (self colinearityOf: lineA value pointB with: lineB )
]
