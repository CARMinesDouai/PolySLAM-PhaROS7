Class {
	#name : #PSProbability,
	#superclass : #Object,
	#instVars : [
		'lineA',
		'lineB',
		'lamda',
		'type'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSProbability class >> from: lineA and: lineB [
	^ self new lineA: lineA; lineB: lineB; yourself.
]

{ #category : #probability }
PSProbability >> farestVertices [
	^self verticesDistance  max value
]

{ #category : #initialization }
PSProbability >> initialize [
	super initialize.
	lamda := 1.0
]

{ #category : #accessing }
PSProbability >> lineA [
	^ lineA
]

{ #category : #accessing }
PSProbability >> lineA: anObject [
	lineA := anObject
]

{ #category : #accessing }
PSProbability >> lineB [
	^ lineB
]

{ #category : #accessing }
PSProbability >> lineB: anObject [
	lineB := anObject
]

{ #category : #probability }
PSProbability >> nearestVertices [
	^self verticesDistance  min value
]

{ #category : #probability }
PSProbability >> probability [
	^self subclassResponsibility 
]

{ #category : #probability }
PSProbability >> probability1 [
	|vertices v1 v2 d1 d2 theta1 theta2  k d gapA gapB lambda1 lambda2 line sum|
	"alway linking if the two lines are adjance"
	(lineA nextLink = lineB) ifTrue:[^1].
	lineA chain = lineB chain ifTrue:[^ 0].
	(lineA value pointB inrangeOf: lineB value pointA) ifTrue: [ ^1 ].
	"otherwise, select the two nerest endpoints"
	vertices := self nearestVertices.
	v1 := vertices first.
	v2 := vertices second.
	(v1 inrangeOf: v2) ifTrue:[
		^ 0
	].
	"not in the same direction"
	(lineA directionVector dotProduct: (lineB directionVector)) < 0 ifTrue:[^0].
	"calculate the linking probability with lineA is the base line"
	"first calcualte the normalized length of the gap between two line"
	d := (lineA value length) + (lineB value length).
	line := lineA value asVMLine.
	gapA := PSLinkedEdge from: lineA value pointA to: lineB value pointA  type: 3. 
	gapB := PSLinkedEdge from: lineA value pointB to: lineB value pointB  type: 3.
	
	"lambda1 := 1.
	lambda2 := 1."
	lambda1  := line distanceToPoint: lineB value pointA.
	lambda2  := line distanceToPoint: lineB value pointB.
	sum := lambda1 + lambda2.
	sum = 0
		ifTrue:[ lambda1 := lambda2 := 0 ]
		ifFalse:[
			lambda1 := lambda1  / sum.
			lambda2 := lambda2 / sum.
		].
	"d1 := (( lineA value pointA dist: lineB value pointA ) + ( lineA value pointB dist: lineB value pointB)) / d."
	d1 := gapA length / d.
	d2 := gapB length / d.
	
	"then calculate the polar angle theta between the gap and the line
	theta should be in range of [-PI/2, PI/2]"
	theta1 := lineA angleWith: gapA.
	(theta1 > ((Float pi) / 2)) ifTrue:[theta1 := (Float pi) - theta1].
	(theta1 < ((Float pi )/ -2)) ifTrue:[theta1 := (Float pi )+ theta1].
	
	theta2 := lineA angleWith: gapB.
	(theta2 > ((Float pi) / 2)) ifTrue:[theta2 := (Float pi) - theta2].
	(theta2 < ((Float pi )/ -2)) ifTrue:[theta2 := (Float pi )+ theta2].
	"Transcript show: theta1; cr; show: theta2; cr; show: d1; cr; show: d2; cr; show: lambda1 ; cr; show: lambda2 ; cr."
	"calculate the constant k which measure the degree of affinity between two lines"
	k := (lambda1*(d1/ ( (theta1 cos) squared ))) + ( (lambda2)*(d2/ ( (theta2 cos) squared ))).
	"return the probability"
	^ (0 - (lamda*k)) exp
]

{ #category : #probability }
PSProbability >> verticesDistance [
	|collection v1 v2 v3 v4|
	v1 := lineA value pointA .
	v2 := lineA value pointB .
	v3 := lineB value pointA .
	v4 := lineB value pointB .
	collection := { 
	(v1 dist: v3) -> { v1. v3 }.
	(v1 dist: v4) -> { v1. v4 }.
	(v2 dist: v3) -> { v2. v3 }.
	(v2 dist: v4) -> { v2. v4 } }.
	
	^collection
]
