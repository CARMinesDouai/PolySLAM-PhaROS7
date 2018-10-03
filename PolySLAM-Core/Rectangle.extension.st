Extension { #name : #Rectangle }

{ #category : #'*PolySLAM-Core' }
Rectangle >> asVMRectangle [
	^(VMRectangle origin: self origin corner: self corner).
]

{ #category : #'*PolySLAM-Core' }
Rectangle >> containsVector: aVector [
	"returns true if the vector intersect with the rectangle or is fully enclosed by it"
	| intersection |
	"first test if the vector is completly to the left or right of the rectangle"
	((aVector pointA < self left) and: [aVector pointB < self left]) ifTrue: [ ^ false ].
	((aVector pointA > self left) and: [aVector pointB > self left]) ifTrue: [ ^ false ].
	
	intersection := VMIntersection intersectLine: aVector withLine: (self bottomLeft vectorTo: self bottomRight).
	((intersection factorU between: 0.0 and: 1.0) and: [intersection factorT between: 0.0 and: 1.0])ifTrue: [ ^ true ].
	intersection := VMIntersection intersectLine: aVector withLine: (self topLeft vectorTo: self topRight).	
	((intersection factorU between: 0.0 and: 1.0) and: [intersection factorT between: 0.0 and: 1.0])ifTrue: [ ^ true ].

	intersection := VMIntersection intersectLine: aVector withLine: (self bottomLeft vectorTo: self topLeft).
	((intersection factorU between: 0.0 and: 1.0) and: [intersection factorT between: 0.0 and: 1.0])ifTrue: [ ^ true ].
	intersection := VMIntersection intersectLine: aVector withLine: (self bottomRight vectorTo: self topRight).	
	((intersection factorU between: 0.0 and: 1.0) and: [intersection factorT between: 0.0 and: 1.0])ifTrue: [ ^ true ].
	
	"test if the vector is fully enclosed by the rectangle"
	
	^ (self containsPoint: aVector pointA) and: [self containsPoint: aVector pointB]

]

{ #category : #'*PolySLAM-Core' }
Rectangle >> flipY [
	^self species point: self origin flipY point: self corner flipY.
]
