Class {
	#name : #VMMapMerger,
	#superclass : #Object,
	#instVars : [
		'localMap',
		'globalMap',
		'listFullOverlap',
		'listPartialOverlap',
		'listNoOverlap',
		'minDistance'
	],
	#category : #'PolySLAM-Core-SLAM - Maps'
}

{ #category : #'as yet unclassified' }
VMMapMerger class >> rendererClass [
	^VMMapMergerRenderer.
]

{ #category : #converting }
VMMapMerger >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #'as yet unclassified' }
VMMapMerger >> getNextLineSeg: lineSeg inCollection: aCollection [
	aCollection do: [ :obj |
		(obj pointA = lineSeg pointB) ifTrue: [
			^obj.
		].
	].
	
	^nil.
]

{ #category : #'as yet unclassified' }
VMMapMerger >> getPrevLineSeg: lineSeg inCollection: aCollection [
	aCollection do: [ :obj |
		(obj pointB = lineSeg pointA) ifTrue: [
			^obj.
		].
	].
	
	^nil.
]

{ #category : #accessing }
VMMapMerger >> globalMap [
	^globalMap.
]

{ #category : #'as yet unclassified' }
VMMapMerger >> initialize [
	
	minDistance := 0.33.
	

]

{ #category : #'as yet unclassified' }
VMMapMerger >> integratePartialOverlap [
	| |
	
	listPartialOverlap do: [ :lineSeg |
	].
]

{ #category : #accessing }
VMMapMerger >> listFullOverlap [
	^listFullOverlap.
]

{ #category : #accessing }
VMMapMerger >> listNoOverlap [
	^listNoOverlap.
]

{ #category : #accessing }
VMMapMerger >> listPartialOverlap [
	^listPartialOverlap.
]

{ #category : #accessing }
VMMapMerger >> localMap [
	^localMap.
]

{ #category : #'public - merging' }
VMMapMerger >> mergeMap: mapA intoMap: mapB [
	
	localMap := mapA.
	globalMap := mapB.
	
	self sortLineSegments: (localMap lineSegments).
	
	globalMap lineSegments addAll: listNoOverlap.
	
	self integratePartialOverlap.

]

{ #category : #'public - merging' }
VMMapMerger >> mergeMap: mapA withMap: mapB [
	
	self deprecated: 'use mergeMap: mapA intoMap: mapB. instead'.
	
	localMap := mapA.
	globalMap := mapB.
	
	localMap lineSegments do: [ :lineSeg |
		"check if the line segment can contribute to the global map"
		"self tryContributeLineSeg: lineSeg."
		self sortLineSegments: (localMap lineSegments).
	].
	
	globalMap lineSegments addAll: listNoOverlap.

]

{ #category : #'as yet unclassified' }
VMMapMerger >> minDistance [
	^minDistance.
]

{ #category : #'as yet unclassified' }
VMMapMerger >> minDistance: aNumber [
	minDistance := aNumber.
]

{ #category : #'as yet unclassified' }
VMMapMerger >> selectStartLineSeg [
	"find the line segment in localMap whose starting point is closest to a line segment in globalMap"
	
	| minDist minLineSeg |
	
	minDist := 99999.
	
	localMap lineSegments do: [ :lineSeg |
		globalMap lineSegments do: [ :globalLineSeg |
			|dist |
			dist := globalLineSeg distanceToPoint: (lineSeg pointA).
			(dist < minDist) ifTrue: [ 
				minLineSeg := lineSeg.
			]
		]
	].
	
	^minLineSeg.

]

{ #category : #'as yet unclassified' }
VMMapMerger >> sortLineSegments: aCollection [
	"sort all line segments from the collection into three categories in regard to globalMap:
	  1) full overlap
	  2) partial overlap
	  3) no overlap
	"
	| minDistA minDistB minLineSegA minLineSegB |
	
	listFullOverlap := OrderedCollection new.
	listPartialOverlap := OrderedCollection new.
	listNoOverlap := OrderedCollection new.
	
	aCollection do: [ :lineSeg |
		minDistA := 999999.
		minLineSegA := nil.
		minDistB := 999999.
		minLineSegB := nil.
		
		globalMap lineSegments do: [ :globalLineSeg |
			| dist |
			
			dist := globalLineSeg distanceToPoint: (lineSeg pointA).
			(dist < minDistA) ifTrue: [
				minDistA := dist.
				minLineSegA := globalLineSeg.
			].
					
			dist := globalLineSeg distanceToPoint: (lineSeg pointB).
			(dist < minDistB) ifTrue: [
				minDistB := dist.
				minLineSegB := globalLineSeg.
			].
		].
	
		((minDistA < minDistance) and: [ minDistB < minDistance ]) ifTrue: [
			listFullOverlap add: lineSeg.
		] ifFalse: [
			((minDistA > minDistance) and: [ minDistB > minDistance ]) ifTrue: [
				listNoOverlap add: lineSeg.
			] ifFalse: [
				(minDistA < minDistance) ifTrue: [
					listPartialOverlap add: { lineSeg. minLineSegA. minLineSegB. minDistB }. 
				] ifFalse: [
					listPartialOverlap add: { lineSeg. minLineSegB. minLineSegA. minDistA }.
				].
			].
		].
	].
	

	
	
	
]

{ #category : #'as yet unclassified' }
VMMapMerger >> tryContributeLineSeg: lineSeg [
	| minDist minLineSeg |
	
	minDist := 999999.
	
	globalMap lineSegments do: [ :globalSeg |
		| dist |
		dist := globalSeg distanceToPoint: (lineSeg pointA).
		(minDist > dist) ifTrue: [
			minDist := dist.
			minLineSeg := globalSeg.
		]
		"todo: break, if we are close enough"
	].
	
	(minDist > (0.5*(minLineSeg length))) ifTrue: [
		"todo: replace 'minLineSeg' with two new line segments, incooperating 'lineSeg pointA' "
	]

]
