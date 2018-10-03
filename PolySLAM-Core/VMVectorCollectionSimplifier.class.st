"
this class simplifies polygons and similar collections of vectors by replacing chains of vectors by new vectors that
approximate the replaced vectors. we currently assume that the input collection is a closed polygon.

note:  we remove the sensor center if one is detected and the opening angle is close to 360 degree. this is done in
#filterChainCollection


Public API

- compute: <inputCollection>
	starts the whole simplification process. the result can be accessed via #result
- result
	answers with the simplified collection. #compute must have been called first, otherwise the answer will be 'nil'
- inlierThreshold: <Float>
	sets the threshold for inlier detection to the provided value. the value is directly passed to VMLineFitter where it
	is actually used.
	

Key Messages

- loop
	the main loop, containing two inner loops:
	1) looping over the vector chains, creating intermediate results via #loopOverChain:
	2) looping over the intermediate results, creating the final result
- loopOverChain: <aVectorChain>
	uses VMLineFitter to find a good approximation for the chain. any inliers will be removed from the chain
	and the process repeated until all vectors in the chain have been handled.
- loopOverResultCollection
	creates the final result by creating a vector for every entry in 'resultCollection' and adding them to 'result' in-order.
	currently wraps around the end, hence creating a closed polygon. note, that the result class is determined by the
	input collection in #compute: however.

"
Class {
	#name : #VMVectorCollectionSimplifier,
	#superclass : #Object,
	#instVars : [
		'input',
		'resultCollection',
		'chainCollection',
		'result',
		'inlierThreshold'
	],
	#category : #'PolySLAM-Core-Line- & Vector Approximation'
}

{ #category : #'as yet unclassified' }
VMVectorCollectionSimplifier class >> compute: input [
	^(self new)
		compute: input;
		yourself
]

{ #category : #'as yet unclassified' }
VMVectorCollectionSimplifier class >> compute: input inlierThreshold: threshold [
	^(self new)
		inlierThreshold: threshold;
		compute: input;
		yourself
]

{ #category : #'rendering support' }
VMVectorCollectionSimplifier class >> rendererClass [
	^ VectorCollectionSimplifierRenderer
]

{ #category : #converting }
VMVectorCollectionSimplifier >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #'as yet unclassified' }
VMVectorCollectionSimplifier >> checkChainLoop [
	"checks if the last chain is actually connected with the first chain. if yes, we
	merge the two chains into a single one."
	chainCollection size < 2 ifTrue: [ ^self ].
	
	chainCollection last last pointB = chainCollection first first pointA ifTrue: [
		chainCollection last last type = chainCollection first first type ifTrue: [
			| oldFirst |
			oldFirst := chainCollection first.
			chainCollection at: 1 put: chainCollection last.
			chainCollection first addAll: oldFirst.
			chainCollection removeLast.
		].
	].
]

{ #category : #public }
VMVectorCollectionSimplifier >> compute: aVectorCollection [
	
	"initialize variables"
	input := aVectorCollection.
	chainCollection := VMVectorChainCollection fromVectorCollection: aVectorCollection.
	resultCollection := OrderedCollection new.
	
	self filterChainCollection.
	self checkChainLoop.
	
	self loop.
	"
	1) create chains (i.e. VMRansacResult instances)
	2) find left/right neighboring chains for all chains
	3) replace chains with single vector
	4) return new vector collection
	"

]

{ #category : #'as yet unclassified' }
VMVectorCollectionSimplifier >> createVectorFromFittingResult: resultIndex [
	"creates a vector for the fitting result at 'resultIndex'. if the delta angle of the
	previouse fitting result and the current fitting result is less than 'minAngle' then
	we compute the two projection points. if they are farther away then 'maxDistance'
	then we create a new vector to connect the projection points, instead of just
	computing the interjection point between the two lines."
	| prevLine nextLine minAngle maxAngle maxDistance pointA pointB r projectionPoints |
	r := resultCollection at: resultIndex.
	prevLine := (resultCollection atWrap: (resultIndex - 1)) line.
	nextLine := (resultCollection atWrap: (resultIndex + 1)) line.
	minAngle := Float twoPi * 15 / 360. "15 degree angle"
	maxAngle := Float twoPi * 170 / 360. "170 degree angle"
	maxDistance := 0.02 squared. "maximum distance before we create a new vector: 2cm"
	
	(((prevLine deltaAngle: r line) abs < minAngle) or: [(prevLine deltaAngle: r line) abs > maxAngle])
		ifTrue: [	
			"we have a flat angle between the previous line and the current line. we need to determine whether we create a small
			vector from the projection points, or use a middle-point as start point of the new vector."
			"Transcript show: 'flat angle detected (1): '; show: ((prevLine deltaAngle: r line) * 360 / Float twoPi) printString; cr."
			
			projectionPoints := self projectionPoints: r vectorCollection first pointA lineA: prevLine lineB: r line.
			(projectionPoints first squaredDistanceTo: projectionPoints second) > maxDistance
				ifTrue: [
					"create vector that connects the previous vector with the new vector that we will create later in this loop iteration"
					pointA := projectionPoints second.
					result add:
						(VMLineSegment
							from: projectionPoints first
							to: pointA
							type: r vectorCollection first type).
					"Transcript show: 'new vector added: ', result last printString; cr."
				] ifFalse: [
					"create a point that would be in the center of the connecting vector"
					pointA := (projectionPoints first + projectionPoints second) * 0.5.
				].
		] ifFalse:[
			"if no flat angle, we just use the intersection point of the previous line - current line intersection"
			pointA := (VMIntersection intersectLine: prevLine withLine: r line) intersectionPoint.
		].
	
	
	pointB := (r line deltaAngle: nextLine) abs < minAngle
		ifTrue: [	
			"Transcript show: 'flat angle detected (2): '; show: ((r line deltaAngle: nextLine) * 360 / Float twoPi) printString; cr."
			
			projectionPoints := self projectionPoints: r vectorCollection last pointB lineA: r line lineB: nextLine.
			(projectionPoints first squaredDistanceTo: projectionPoints second) > maxDistance
				ifTrue: [
					r line projectionPoint: (resultCollection atWrap: (resultIndex + 1)) vectorCollection first pointA.
				] ifFalse: [
					(projectionPoints first + projectionPoints second) * 0.5.
				].
		] ifFalse: [
			(VMIntersection intersectLine: r line withLine: nextLine) intersectionPoint.
		].
	
	
	result add: (VMLineSegment from: pointA to: pointB type: r vectorCollection first type).

]

{ #category : #public }
VMVectorCollectionSimplifier >> filterChainCollection [
	"this method checks if the last chain contains only two overlapping frontiers.
	this happens if the laser scan has an opening angle of (about) 360 degree.
	In that case we are shorting the chain to a single vector by hand"
	| chain |
	chain := chainCollection last.
	chain size = 2 ifFalse: [ ^self ].
	chain first isFrontier ifFalse: [ ^self ].
	chain second isFrontier ifFalse: [ ^self ].
	
	(chain first pointA dist: chain second pointB) < 0.05 ifTrue: [
		chainCollection removeLast.
		chainCollection last add: (VMLineSegment from: chain first pointA to: chain last pointB type: chainCollection last first type).
	].
	

]

{ #category : #'GT Inspector' }
VMVectorCollectionSimplifier >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
		
]

{ #category : #initialization }
VMVectorCollectionSimplifier >> initialize [
	super initialize.
	inlierThreshold := 0.02.
]

{ #category : #accessing }
VMVectorCollectionSimplifier >> inlierThreshold [
	^ inlierThreshold
]

{ #category : #accessing }
VMVectorCollectionSimplifier >> inlierThreshold: aNumber [
	aNumber ifNotNil: [ inlierThreshold := aNumber. ].
]

{ #category : #accessing }
VMVectorCollectionSimplifier >> input [
	^input
]

{ #category : #accessing }
VMVectorCollectionSimplifier >> input: aVectorCollection [
	input := aVectorCollection.
]

{ #category : #'basic algorithm' }
VMVectorCollectionSimplifier >> loop [
	"computation steps:
	1) check abort conditions
	2) split input into chains
		2.1) find chain (use sampleableVectors to draw samples from)
		2.2) remove chain from sampleableVectors
	"
	
	chainCollection do: [ :vectorChain |
		self loopOverChain: vectorChain.
		"[ self abortLoop ] whileFalse: [
			self iterateOnce.
		]."
	].
	
	self loopOverResultCollection.

]

{ #category : #'basic algorithm' }
VMVectorCollectionSimplifier >> loopOverChain: vectorChain [
	| startIndex fittingResult |
	startIndex := 1.
	
	"initial run with full length"
	fittingResult := (VMLineFitter new) inlierThreshold: inlierThreshold;
		compute: vectorChain startVector: vectorChain first.
	startIndex := startIndex + fittingResult vectorCollection size.
	resultCollection add: fittingResult.
	
	"if the line fitting does not include all vectors from the chain, we continue with the remaining vectors until all are covered"
	[startIndex <= vectorChain size] whileTrue: [
		fittingResult := (VMLineFitter new) inlierThreshold: inlierThreshold;
			compute: (vectorChain collect: [:v|v] from: startIndex to: vectorChain size) startVector: (vectorChain at: startIndex).
		startIndex := startIndex + fittingResult vectorCollection size.
		resultCollection add: fittingResult.
	].

]

{ #category : #'basic algorithm' }
VMVectorCollectionSimplifier >> loopOverResultCollection [
	result := input species new.
	
	resultCollection doWithIndex: [ :r :index |
		self createVectorFromFittingResult: index.
	].
]

{ #category : #accessing }
VMVectorCollectionSimplifier >> maxIterations [
	^maxIterations
]

{ #category : #accessing }
VMVectorCollectionSimplifier >> maxIterations: anInteger [
	maxIterations := anInteger.
]

{ #category : #'as yet unclassified' }
VMVectorCollectionSimplifier >> projectionPoints: aPoint lineA: lineA lineB: lineB [
	| startPoint endPoint |
	
	startPoint := lineA projectionPoint: aPoint.
	endPoint := lineB projectionPoint: aPoint.
	
	^{ startPoint.  endPoint }
]

{ #category : #accessing }
VMVectorCollectionSimplifier >> result [
	^ result
]

{ #category : #accessing }
VMVectorCollectionSimplifier >> resultCollection [
	"for debugging and visualization; not part of the public API.
	returns a collection of VMLineFittingResult instances.
	to receive the simplified vectors, use #result instead."
	^resultCollection
]
