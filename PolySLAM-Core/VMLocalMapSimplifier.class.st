Class {
	#name : #VMLocalMapSimplifier,
	#superclass : #Object,
	#instVars : [
		'oldCollection',
		'newCollection',
		'startIndex',
		'endIndex',
		'maxError'
	],
	#category : #'PolySLAM-Core-SLAM - Maps'
}

{ #category : #accessing }
VMLocalMapSimplifier >> endIndex: anInteger [
	endIndex := anInteger.
]

{ #category : #helper }
VMLocalMapSimplifier >> ifNotMergeAbleType: aType do: aBlock [
	^self ifNotMergeAbleType: aType do: aBlock otherwiseDo: [].
]

{ #category : #'as yet unclassified' }
VMLocalMapSimplifier >> ifNotMergeAbleType: aType do: aBlock otherwiseDo: bBlock [
	1 halt.
	(aType = 1) ifTrue: [
		^bBlock value.
	].
	
	^aBlock value.
]

{ #category : #initialization }
VMLocalMapSimplifier >> initialize [
	maxError := 0.01.
	
]

{ #category : #accessing }
VMLocalMapSimplifier >> maxError [
	^maxError.
]

{ #category : #accessing }
VMLocalMapSimplifier >> maxError: error [
	maxError := error.
]

{ #category : #helper }
VMLocalMapSimplifier >> meanSquareError [
	| index squareErrorSum tempLine pointCount |
	
	tempLine := VMLineSegment from: (oldCollection at: startIndex) pointA to: (oldCollection at: endIndex) pointB type: ((oldCollection at: startIndex) type).
	index := startIndex + 1.
	squareErrorSum:= 0.
	pointCount := 0.
	
	[ index <= endIndex ] whileTrue: [
		| dist |
		dist := tempLine distanceToPoint: (oldCollection at: index) pointA.
		squareErrorSum := squareErrorSum + (dist * dist).
		pointCount := pointCount + 1.
		index := index + 1.
	].
	
	^squareErrorSum / pointCount.
]

{ #category : #private }
VMLocalMapSimplifier >> mergeFrom: start to: end [
	| pointA pointB type |
	
	pointA := (oldCollection at: start) pointA.
	pointB := (oldCollection at: end) pointB.
	type := (oldCollection at: start) type.
	
	newCollection add: (VMLineSegment
		from: pointA
		to: pointB
		type: type).

]

{ #category : #accessing }
VMLocalMapSimplifier >> newCollection [
	^newCollection.
]

{ #category : #accessing }
VMLocalMapSimplifier >> oldCollection: aCollection [
	oldCollection := aCollection.
]

{ #category : #'public - simplifying' }
VMLocalMapSimplifier >> simplify: aCollection [
	
	oldCollection := aCollection.
	newCollection := OrderedCollection new.
	startIndex := 1.
	endIndex := 2.
	
	[ (endIndex) <= (oldCollection size+1) ] whileTrue: [
		(oldCollection at: startIndex) type
			ifMergeableTypeDo: [ self tryMerge. ]
			otherwiseDo: [
				newCollection add: (oldCollection at: startIndex).
				startIndex := startIndex + 1.
				endIndex := startIndex + 1.
			].
		
		"
		self ifNotMergeAbleType: (oldCollection at: startIndex) type do: [
			newCollection add: (oldCollection at: startIndex).
			startIndex := startIndex + 1.
			endIndex := startIndex + 1.
		] otherwiseDo: [
			self tryMerge.
		]."
	].
	
	^newCollection.
]

{ #category : #accessing }
VMLocalMapSimplifier >> startIndex: anInteger [
	startIndex := anInteger.
]

{ #category : #helper }
VMLocalMapSimplifier >> tryMerge [
	
	(endIndex > oldCollection size) ifTrue: [
		self mergeFrom: startIndex to: (endIndex - 1).
		startIndex := endIndex.
		endIndex := startIndex + 1.
		^true.
	].
	
	
	(oldCollection at: endIndex) type ifMergeableTypeDo: [] otherwiseDo: [
		self mergeFrom: startIndex to: (endIndex - 1).
		startIndex := endIndex.
		endIndex := startIndex + 1.
		^true.
	].
	"
	self ifNotMergeAbleType: (oldCollection at: endIndex) type do: [
		self mergeFrom: startIndex to: (endIndex - 1).
		startIndex := endIndex.
		endIndex := startIndex + 1.
		^true.
	]."
	
	(self meanSquareError > maxError) ifTrue: [
		self mergeFrom: startIndex to: (endIndex - 1).
		startIndex := endIndex.
		endIndex := startIndex + 1.
		^true.
	].
	
	endIndex := endIndex + 1.
	^self tryMerge

]
