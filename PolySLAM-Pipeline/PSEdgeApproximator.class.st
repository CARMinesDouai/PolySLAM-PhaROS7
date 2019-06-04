Class {
	#name : #PSEdgeApproximator,
	#superclass : #Object,
	#instVars : [
		'segments',
		'approxChain',
		'score',
		'th',
		'firstEdge',
		'lastEdge'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSEdgeApproximator class >> from: list [
	^ self new segments: list; yourself
]

{ #category : #accessing }
PSEdgeApproximator >> approxChain [
	^ approxChain
]

{ #category : #approximation }
PSEdgeApproximator >> approximate [
	
	self approximateChain:(self loopOverChain: self makeChain ).
	"{chain. approxChain } asRenderableElement inspect."
]

{ #category : #approximation }
PSEdgeApproximator >> approximateChain: fitterResult [
	|startPoint endPoint line segment segmentA segmentB  lastPoint adjacenLine|
	approxChain := DoublyConnectedEdgeList new.
	line := fitterResult first line asVMLine.
	
	"find start and end point of the  chain"
	segmentB := fitterResult last vectorCollection last.
	endPoint := segmentB pointB.
	
	segmentA := fitterResult first vectorCollection first.
	startPoint := "line projectionPoint: "segmentA pointA.
	
	lastPoint := startPoint.
	segment := segmentA.
	"get all intersection point two adjacenLine"
	fitterResult removeFirst.
	fitterResult do:[:e|
		adjacenLine := e line asVMLine.
		line ifIntersectsWith: adjacenLine  do: [:point :u :t |
			(lastPoint dist: point) > 1e-6
				ifTrue:[
				approxChain add:(VMLineSegment from: lastPoint to: point  type: segment type) asPSLinkedEdge.
				].
			lastPoint := point.
		].
		segment := e vectorCollection first.
		line := adjacenLine.
	].
	(lastPoint dist:endPoint) > 1e-6
		ifTrue:[
		approxChain add:(VMLineSegment from: lastPoint to: endPoint  type: segment type) asPSLinkedEdge.
		]
	"approxChain firstLink previousLink: segmentA previousLink.
	approxChain lastLink nextLink: segmentB  nextLink"
]

{ #category : #converting }
PSEdgeApproximator >> asRenderableElement [
	^ approxChain  asRenderableElement
]

{ #category : #accessing }
PSEdgeApproximator >> bounds [
	^ approxChain bounds 
]

{ #category : #accessing }
PSEdgeApproximator >> firstEdge [
	^ firstEdge
]

{ #category : #testing }
PSEdgeApproximator >> hasId: anId [
	^(self segments collect:[:e| e id]) includes: anId
]

{ #category : #initialization }
PSEdgeApproximator >> initialize [
	super initialize.
	segments := OrderedCollection new.
	th := 0.05
]

{ #category : #accessing }
PSEdgeApproximator >> lastEdge [
	^ lastEdge
]

{ #category : #'basic algorithm' }
PSEdgeApproximator >> loopOverChain: vectorChain [
	| startIndex fittingResult resultCollection scoring|
	scoring := VMLFScore new.
	startIndex := 1.
	resultCollection := OrderedCollection new.
	"initial run with full length"
	fittingResult := (VMLineFitter new) scoring: scoring; inlierThreshold: th;
		compute: vectorChain startVector: vectorChain first.
	startIndex := startIndex + fittingResult vectorCollection size.
	resultCollection add: fittingResult.
	
	"if the line fitting does not include all vectors from the chain, we continue with the remaining vectors until all are covered"
	[startIndex <= vectorChain size] whileTrue: [
		fittingResult := (VMLineFitter new) scoring: scoring; inlierThreshold: th;
			compute: (vectorChain collect: [:v|v] from: startIndex to: vectorChain size) startVector: (vectorChain at: startIndex).
		startIndex := startIndex + fittingResult vectorCollection size.
		resultCollection add: fittingResult.
	].
	^ resultCollection 
]

{ #category : #'basic algorithm' }
PSEdgeApproximator >> makeChain [
	| dvector  tree point chain lA lB ltype |
	dvector := self segments first directionVector.

	tree := BTree order: 4.
	self segments do:[:l|
		l asPSVertices do:[:v|
			tree at: (PSVertexDirectionKey from: v unitVector: dvector) put:v.
		]	
	].
	"now make the chain"
	firstEdge := tree first segments first.
	lastEdge  := tree last segments first.
	chain := VMVectorChainCollection new.
	point := nil.
	tree do:[:v|
		point
			ifNil: [
				point := v.
			]
			ifNotNil: [
				lA := point segments first value.
				lB := v segments first value.
				lA type = lB type
					ifTrue:[ ltype := lA type asInteger]
					ifFalse:[
						point isEnd
							ifTrue: [ltype := lB type asInteger ]
							ifFalse:[ltype := lA type asInteger]
					].
				chain add: (VMLineSegment pointA: point asPoint pointB: v asPoint  type: ltype).
				point := v
			] 
	].
	^ chain
]

{ #category : #accessing }
PSEdgeApproximator >> nextEdge [
	^ lastEdge nextEdge
]

{ #category : #accessing }
PSEdgeApproximator >> previousEdge [
	^ firstEdge previousEdge 
]

{ #category : #accessing }
PSEdgeApproximator >> score [
	^ score
]

{ #category : #accessing }
PSEdgeApproximator >> segments [
	^ segments
]

{ #category : #accessing }
PSEdgeApproximator >> segments: anObject [
	segments := anObject
]

{ #category : #accessing }
PSEdgeApproximator >> th [
	^ th
]

{ #category : #accessing }
PSEdgeApproximator >> th: anObject [
	th := anObject
]

{ #category : #accessing }
PSEdgeApproximator >> visited: bool [
	self segments do:[:e| e visited: bool]
]
