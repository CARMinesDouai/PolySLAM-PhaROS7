Class {
	#name : #VMLocalMapMerger,
	#superclass : #Object,
	#instVars : [
		'collectionA',
		'infoCollection',
		'globalMapFrame'
	],
	#category : #'PolySLAM-Core-SLAM - Maps'
}

{ #category : #'as yet unclassified' }
VMLocalMapMerger class >> rendererClass [
	^VMLocalMapMergerRenderer.
]

{ #category : #'render support' }
VMLocalMapMerger >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #helper }
VMLocalMapMerger >> checkStartInfo: infoObj ifObstacle: obstacleBlock ifFrontier: frontierBlock ifIsolated: isolatedBlock [
	| lineSeg dist |
	
	dist := infoObj startDist.
	((dist isNil) or: [dist > 0.3]) ifTrue: [ ^isolatedBlock value ].
	
	lineSeg := infoObj startLineSeg.
	
	lineSeg isObstacle ifTrue: [
		^obstacleBlock value: lineSeg.
	].
	
	lineSeg isFrontier ifTrue: [
		^frontierBlock value: lineSeg.
	].
	
	self error: 'unsupported case: start line seg is neither obstacle nor frontier'.

]

{ #category : #helper }
VMLocalMapMerger >> computeDeltaAngleA: radA angleB: radB [
	"returns the delta angle (radians) in the range (-pi, pi]. the two angles are expected to be in radians."
	| delta |
	
	delta := radA - radB.
	
	(delta <= (Float pi negated)) ifTrue: [ delta := Float twoPi + delta ].
	(delta > (Float pi)) ifTrue: [ delta := delta - (Float twoPi). ].
	
	^delta.

]

{ #category : #helper }
VMLocalMapMerger >> computeInfoCollection: collection [
	"takes a collection of VMMergeInfo objects (with only the line segment set) and computes the remaining values, in particular the alignment score."
	collection do: [ :infoObj |
		
		self computeInfoObj: infoObj.
		
		Transcript
			show: infoObj printString;
			cr.
		
	].


]

{ #category : #helper }
VMLocalMapMerger >> computeInfoObj: infoObj [
	"compute the info for the line segment closest to 'infoObj lineSeg pointA'."
	self computeStartInfoObj: infoObj.
	
	self computeUntilEndInfoObj: infoObj.

]

{ #category : #helper }
VMLocalMapMerger >> computeNextFactor: nextLineSeg infoObj: infoObj [
	| factor |
	
	factor := nextLineSeg factorToPointProjection: (infoObj lineSeg pointB).
	
	^factor.
	

]

{ #category : #helper }
VMLocalMapMerger >> computeStartInfoObj: infoObj [
	| sortedDistances testLineSeg dist angle factor |
	
	"compute closest line segment to 'infoObj lineSeg pointA'."
	sortedDistances := self sortedDistFromPoint: (infoObj lineSeg pointA) toLineSegments: collectionA.
	testLineSeg := collectionA at: sortedDistances first first.
	
	"if we encounter a frontier (i.e. non-obstacle), we set a high default score and return immediately"
	(testLineSeg isObstacle) ifFalse: [
		infoObj alignmentScore: 99.9.
		"todo: check if a possible obstacle to connect to is nearby"
		^self.
	].
	
	"compute distance and delta angle"
	dist := sortedDistances first second.
	angle := (self computeDeltaAngleA: (infoObj lineSeg angle) angleB: (testLineSeg angle)) abs.
	infoObj
		startDist: dist;
		startDeltaAngle: angle;
		alignmentScore: (infoObj computeScore).
	
	"check if the projection point lies within the line segment (factor < 1) or outside (factor > 1)"
	factor := testLineSeg factorToPointProjection: (infoObj lineSeg pointB).
	
	infoObj
		startLineSeg: testLineSeg;
		startProjectionFactor: factor.
	
	Transcript cr; show: '  i=', (collectionA indexOf: testLineSeg) printString, ', f=', factor printString, ', s=', infoObj alignmentScore printString; cr.
	

]

{ #category : #helper }
VMLocalMapMerger >> computeUntilEndInfoObj: infoObj [
	| maxIterations factor testLineSeg |
	
	testLineSeg := infoObj startLineSeg.
	maxIterations := 20.
	factor := infoObj startProjectionFactor ifNil: [ 0.0 ] ifNotNil: [ infoObj startProjectionFactor ].
	
	[ factor > 1.0 ] whileTrue: [
		| newScore dist angle |
		maxIterations := maxIterations - 1.
		testLineSeg := self getNextLineSeg: testLineSeg.
		
		"if we encounter a non-obstacle (i.e. frontier), we set a high default score and return immediately"
		(testLineSeg isObstacle) ifFalse: [
			infoObj alignmentScore: 99.9.
			^self.
		].
		
		dist := infoObj lineSeg distanceToPoint: (testLineSeg pointA).
		angle := (self computeDeltaAngleA: (infoObj lineSeg angle) angleB: (testLineSeg angle)) abs.
		newScore := infoObj computeScoreDist: dist angle: angle.
		(newScore > (infoObj alignmentScore)) ifTrue: [
			infoObj alignmentScore: newScore.
		].
				
		factor := self computeNextFactor: testLineSeg infoObj: infoObj.
		
		Transcript show: '  i=', (collectionA indexOf: testLineSeg) printString, ', f=', factor printString, ', s=', newScore printString; cr.
		
		(maxIterations < 0) ifTrue: [
			Transcript show: 'max iteration count reach - aborting loop'; cr.
			^self.
		].
	].

]

{ #category : #helper }
VMLocalMapMerger >> findNearestStartLineSeg: lineSeg inCollection: collection [
	"returns a collection of pairs. each pair contains the index of the tested line segment in 'collection' and the computed distance between pointA of 'lineSeg' and the tested line segment.
	the line segment closest to 'lineSeg pointA' is the first line segment in the collection: sortedDistCollection first second"
	| point sortedDistCollection |
	
	point := lineSeg pointA.
	
	sortedDistCollection := (collection collectWithIndex: [ :each :index |
		{ index. each distanceToPoint: point. }
	]) sort: [ :a :b |
		(a last) < (b last)
	].
	
	^sortedDistCollection.

]

{ #category : #'render support' }
VMLocalMapMerger >> frame [
	^globalMapFrame.
]

{ #category : #helper }
VMLocalMapMerger >> getNextLineSeg: currentLineSeg [
	| curEndPoint |
	
	curEndPoint := currentLineSeg pointB.
	
	collectionA do: [ :lineSeg |
		(lineSeg pointA = curEndPoint) ifTrue: [
			^lineSeg.
		].
	].
	
	self error: 'unable to find next line segment in collection'.
]

{ #category : #'render support' }
VMLocalMapMerger >> infoCollection [
	^infoCollection.
]

{ #category : #'public - merging' }
VMLocalMapMerger >> mergeMap: mapA withMap: mapB [
	| frame |

	frame := mapB tf multiplyLeft: (mapA tf inverse).
	
	"globalMapFrame is for debugging and visualization only"
	globalMapFrame := mapA tf.
	
	collectionA := mapA lineSegments.
	infoCollection := mapB lineSegments collect: [ :lineSegObj |
		VMMergeInfo lineSeg: (lineSegObj copy transform: frame)
	].
	
	self computeInfoCollection: infoCollection.
	
	self mergeUsingInfoCollection: infoCollection.
	
	^self renderCollection.


]

{ #category : #helper }
VMLocalMapMerger >> mergeObstacleInfo: infoObj [
	^self mergeObstacleInfo: infoObj startLineSeg: infoObj startLineSeg.
]

{ #category : #helper }
VMLocalMapMerger >> mergeObstacleInfo: infoObj startLineSeg: start [
	"merge the line segment from infoObj with collectionA, using the starting line segment start as first merging object."
	| infoLineSeg collection |
	
	infoLineSeg := infoObj lineSeg.
	collection := OrderedCollection new.
	
	collection add: (  VMLineSegment from: (start pointA) to: (infoLineSeg pointA) type: (start type)  ).
	collection add:(  VMLineSegment from: (infoLineSeg pointA) to: (start pointB) type: (start type)  ).
	
	"remove 'start' from the collection, replacing it with the new line segment"
	"find the end point for the new line segment"
	


]

{ #category : #helper }
VMLocalMapMerger >> mergeUsingInfoCollection: collection [
	
	collection do: [ :infoObj |
		self checkStartInfo: infoObj
			ifObstacle: [ :startLineSeg | self mergeObstacleInfo: infoObj ]
			ifFrontier: []
			ifIsolated: []
	].
	

]

{ #category : #'render support' }
VMLocalMapMerger >> renderCollection [
	"returns a collection of renderable line segments."
	| renderCollection |
	
	renderCollection := self renderCollectionA.
	renderCollection addAll: (self renderCollectionB).
	
	^renderCollection.


]

{ #category : #'render support' }
VMLocalMapMerger >> renderCollectionA [
	"returns a collection of renderable line segments."
	| renderCollection |
	
	renderCollection := OrderedCollection new.
	
	collectionA do: [ :lineSeg |
		| rObj |
		
		rObj := lineSeg asRenderableElement color: Color blue..
		
		lineSeg isFrontier ifTrue: [
			rObj dashStyle: #( "fill" 0.05 "gap" 0.05).
		].
		
		renderCollection add: (rObj).
	].
	
	^renderCollection.


]

{ #category : #'render support' }
VMLocalMapMerger >> renderCollectionB [
	"returns a collection of renderable line segments."
	| renderCollection |
	
	renderCollection := OrderedCollection new.
	
	infoCollection do: [ :infoObj |
		| hue rObj |
		
		hue := (120.0 - (360 * infoObj alignmentScore)).
		hue < 0 ifTrue: [ hue := 0.0 ].
		
		"infoObj lineSeg isFrontier ifTrue: [ hue := 310. ]."
		
		rObj := infoObj lineSeg asRenderableElement.
		infoObj lineSeg isFrontier ifTrue: [
			rObj dashStyle: #( "fill" 0.05 "gap" 0.05).
		].
		
		renderCollection add: (rObj
			color: (Color h: hue s: 1 v: 1);
			yourself
		).
		
	].
	^renderCollection.


]

{ #category : #helper }
VMLocalMapMerger >> sortedDistFromLine: lineSeg toLineSegments: collection [
	"returns a collection of pairs. each pair contains the index of the line segment in 'collection' and
	the distance between 'lineSeg' and the corresponding line segment in 'collection'. line segments
	in 'collection' that are not obstacles are ignored."
	| distances sortedCollection |
	
	distances := (collection select: [ :eachLineSeg |
			eachLineSeg isObstacle
	]) collectWithIndex: [ :eachLineSeg :index |
		"{index.  lineSeg distanceToLineSeg: eachLineSeg}"
		{ index.  eachLineSeg distanceToLineSeg: lineSeg }
	].

	sortedCollection := distances sort: [ :a :b |
		(a second) < (b second)
	].
	
	^sortedCollection.
]

{ #category : #helper }
VMLocalMapMerger >> sortedDistFromPoint: aPoint toLineSegments: collection [
	"returns a collection of pairs. each pair contains the index of the line segment in 'collection' and
	the distance between 'lineSeg' and the corresponding line segment in 'collection'. line segments
	that are not obstacles (i.e. frontiers) are ignored."
	| distances sortedCollection |
	
	"distances := (collection select: [ :eachLineSeg |
			eachLineSeg isObstacle
	]) collectWithIndex: [ :eachLineSeg :index |
		{ index.  eachLineSeg distanceToPoint: aPoint }
	].
	"
	distances := collection collectWithIndex: [ :eachLineSeg :index |
		{ index.  eachLineSeg distanceToPoint: aPoint }
	].

	sortedCollection := distances sort: [ :a :b |
		(a second) < (b second)
	].
	
	^sortedCollection.
]
