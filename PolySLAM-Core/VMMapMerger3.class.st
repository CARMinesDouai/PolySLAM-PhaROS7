Class {
	#name : #VMMapMerger3,
	#superclass : #Object,
	#instVars : [
		'gridContainer',
		'globalMap'
	],
	#category : #'PolySLAM-Core-SLAM - Maps'
}

{ #category : #'as yet unclassified' }
VMMapMerger3 >> findNearbyLineSegments: aLineSeg inCollection: aCollection [
	| collectionIntersects collectionNear |
	
	collectionIntersects := OrderedCollection new.
	collectionNear := OrderedCollection new.
	
	aCollection do: [ :obj |
		aLineSeg distanceToLineSeg: obj
			ifIntersectsDo: [ :iPoint :k | collectionIntersects add: {obj. iPoint} ]
			otherwiseDo: [ :dist |  ]
	].
]

{ #category : #accessing }
VMMapMerger3 >> globalMap [
	^globalMap.
]

{ #category : #accessing }
VMMapMerger3 >> globalMap: aMap [
	globalMap := aMap.
]

{ #category : #'as yet unclassified' }
VMMapMerger3 >> mergeMap: aMap [

]

{ #category : #'as yet unclassified' }
VMMapMerger3 >> walkLineSegments: aCollection [
	aCollection do: [ :aPoint |
	].
]
