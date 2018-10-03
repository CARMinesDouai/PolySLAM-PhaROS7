Class {
	#name : #VMMapMerger2,
	#superclass : #Object,
	#instVars : [
		'gridContainer',
		'globalMap',
		'listFullOverlap',
		'listPartialOverlap',
		'listNoOverlap'
	],
	#category : #'PolySLAM-Core-SLAM - Maps'
}

{ #category : #accessing }
VMMapMerger2 >> globalMap [
	^globalMap.
]

{ #category : #accessing }
VMMapMerger2 >> globalMap: aMap [

	self reset.
	
	globalMap := aMap.
	gridContainer insertAll: aMap lineSegments.
]

{ #category : #accessing }
VMMapMerger2 >> gridContainer [
	^gridContainer.
]

{ #category : #initialization }
VMMapMerger2 >> initialize [
	self reset.
]

{ #category : #actions }
VMMapMerger2 >> merge: aMap [
	self sortLineSegments: aMap lineSegments.
	
	globalMap lineSegments addAll: listNoOverlap.
	gridContainer insertAll: listNoOverlap.
	

]

{ #category : #initialization }
VMMapMerger2 >> reset [
	gridContainer := VMGridContainer new.
]

{ #category : #private }
VMMapMerger2 >> sortLineSegments: aCollection [
	"sort all line segments from the collection into three categories in regard to globalMap:
	  1) full overlap
	  2) partial overlap
	  3) no overlap
	"
	| minDistA minDistB minLineSegA minLineSegB resultA resultB minSquareDist minDistance |
	
	minDistance := 0.25.
	minSquareDist := minDistance squared.
	
	listFullOverlap := OrderedCollection new.
	listPartialOverlap := OrderedCollection new.
	listNoOverlap := OrderedCollection new.
	
	aCollection do: [ :lineSeg |
		minDistA := 999999.
		minLineSegA := nil.
		minDistB := 999999.
		minLineSegB := nil.
		
		resultA := gridContainer findNearest: lineSeg pointA abortDist: 0.5.
		resultB := gridContainer findNearest: lineSeg pointB abortDist: 0.5.
		
		(resultA squareDist < minSquareDist) ifTrue: [ minDistA := resultA squareDist sqrt. minLineSegA := resultA object. ].
		(resultB squareDist < minSquareDist) ifTrue: [ minDistB := resultB squareDist sqrt. minLineSegB := resultB object. ].
		
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
