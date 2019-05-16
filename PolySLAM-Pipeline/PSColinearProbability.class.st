Class {
	#name : #PSColinearProbability,
	#superclass : #PSProbability,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'as yet unclassified' }
PSColinearProbability >> colinearity [
	|line d1 d2 gapA gapB lambda1 lambda2 sum theta1 theta2 k d reward|
	"not in the same direction"
	(lineA directionVector dotProduct: (lineB directionVector)) < 0 ifTrue:[^0].
	"calculate the linking probability with lineA is the base line"
	"first calcualte the normalized length of the gap between two line"
	d := (lineA value length) + (lineB value length).
	line := lineA value asVMLine.
	gapA := PSLinkedEdge from: lineA value pointA asPoint to: lineB value pointA asPoint  type: 3. 
	gapB := PSLinkedEdge from: lineA value pointB asPoint to: lineB value pointB asPoint  type: 3.
	
	"lambda1 := 1.
	lambda2 := 1."
	lambda1  := line distanceToPoint: lineB value pointA.
	lambda2  := line distanceToPoint: lineB value pointB.
	sum := lambda1 + lambda2.
	sum = 0
		ifTrue:[ lambda1 := lambda2 := 1 ]
		ifFalse:[
			lambda1 := lambda1  / sum.
			lambda2 := lambda2 / sum.
		].
	"d1 := (( lineA value pointA dist: lineB value pointA ) + ( lineA value pointB dist: lineB value pointB)) / d."
	d1 := d2 := 0.
	theta1 := theta2 := 0.
	gapA ifNotNil: [  
		d1 := gapA length / d.
		theta1 := lineA angleWith: gapA.].
	gapB ifNotNil: [  
		d2 := gapB length / d.
		theta2 := lineA angleWith: gapB.].
	d1 + d2 > d ifTrue:[^ 0].
	"then calculate the polar angle theta between the gap and the line
	theta should be in range of [-PI/2, PI/2]"

	(theta1 > ((Float pi) / 2)) ifTrue:[theta1 := (Float pi) - theta1].
	(theta1 < ((Float pi )/ -2)) ifTrue:[theta1 := (Float pi )+ theta1].
	(theta2 > ((Float pi) / 2)) ifTrue:[theta2 := (Float pi) - theta2].
	(theta2 < ((Float pi )/ -2)) ifTrue:[theta2 := (Float pi )+ theta2].
	"Transcript show: theta1; cr; show: theta2; cr; show: d1; cr; show: d2; cr; show: lambda1 ; cr; show: lambda2 ; cr."
	"calculate the constant k which measure the degree of affinity between two lines"
	k := (lambda1*(d1/ ( (theta1 cos squared)  ))) + ( (lambda2)*(d2 / ( (theta2 cos squared)))).
	"calculate the compensate/penality if the two line are/arenot actually overlap"
	reward := ((0 - ((lineA value pointA dist: lineB value pointB) / d)) exp) max: k.
	"return the probability"
	^ (0 - (lamda*k)) exp
]

{ #category : #'as yet unclassified' }
PSColinearProbability >> colinearity1 [
	|line d1 d2 gapA gapB lambda1 lambda2 sum theta1 theta2 k d reward l1 l2|
	"not in the same direction"
	(lineA directionVector dotProduct: (lineB directionVector)) < 0 ifTrue:[^0].
	"calculate the linking probability with lineA is the base line"
	"first calcualte the normalized length of the gap between two line"
	d := (lineA value length) + (lineB value length).
	line := lineA value asVMLine.
	l1 := PSLinkedEdge from: lineA value pointA to: lineB value pointA  type: 3.
	l2 := PSLinkedEdge from: lineA value pointA to: lineB value pointB  type: 3.
	((l1 notNil) & (l2 notNil) ) ifTrue:[
		gapA := l1 length < l2 length ifTrue: [ l1 ] ifFalse: [ l2 ].
	].
	
	l1 := PSLinkedEdge from: lineA value pointB to: lineB value pointA  type: 3.
	l2 := PSLinkedEdge from: lineA value pointB to: lineB value pointB  type: 3.
	((l1 notNil) & (l2 notNil) ) ifTrue:[
		gapB := l1 length < l2 length ifTrue: [ l1 ] ifFalse: [ l2 ].	
	].
	
	"lambda1 := 1.
	lambda2 := 1."
	lambda1  := line distanceToPoint: lineB value pointA.
	lambda2  := line distanceToPoint: lineB value pointB.
	sum := lambda1 + lambda2.
	sum = 0
		ifTrue:[ lambda1 := lambda2 := 1 ]
		ifFalse:[
			lambda1 := lambda1  / sum.
			lambda2 := lambda2 / sum.
		].
	"d1 := (( lineA value pointA dist: lineB value pointA ) + ( lineA value pointB dist: lineB value pointB)) / d."
	d1 := d2 := 0.
	theta1 := theta2 := 0.
	gapA ifNotNil: [  
		d1 := gapA length / d.
		theta1 := lineA angleWith: gapA.].
	gapB ifNotNil: [  
		d2 := gapB length / d.
		theta2 := lineA angleWith: gapB.].
	
	"then calculate the polar angle theta between the gap and the line
	theta should be in range of [-PI/2, PI/2]"

	(theta1 > ((Float pi) / 2)) ifTrue:[theta1 := (Float pi) - theta1].
	(theta1 < ((Float pi )/ -2)) ifTrue:[theta1 := (Float pi )+ theta1].
	(theta2 > ((Float pi) / 2)) ifTrue:[theta2 := (Float pi) - theta2].
	(theta2 < ((Float pi )/ -2)) ifTrue:[theta2 := (Float pi )+ theta2].
	"Transcript show: theta1; cr; show: theta2; cr; show: d1; cr; show: d2; cr; show: lambda1 ; cr; show: lambda2 ; cr."
	"calculate the constant k which measure the degree of affinity between two lines"
	k := (lambda1*(d1/ ( (theta1 cos squared)  ))) + ( (lambda2)*(d2 / ( (theta2 cos squared)))).
	"calculate the compensate/penality if the two line are/arenot actually overlap"
	reward := ((0 - ((lineA value pointA dist: lineB value pointB) / d)) exp) max: k.
	"return the probability"
	^ (0 - (lamda*k)) exp
]

{ #category : #probability }
PSColinearProbability >> probability [
	"alway linking if the two lines are adjance"
	lineA chain = lineB chain ifTrue:[^ 0].
	^ self colinearity
]
