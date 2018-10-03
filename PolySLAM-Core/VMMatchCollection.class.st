"
This collection is derived from an OrderedCollection. It stores VMMatchPair objects, which are pairs of point-like objects that are deemed corresponding with each other by the ICP algorithm.

- squaredError
		computes the square error, which is the sum over the squared euclidean distance between the corresponding points.
- asMatchCollection
		returns self

"
Class {
	#name : #VMMatchCollection,
	#superclass : #OrderedCollection,
	#instVars : [
		'inlierHash'
	],
	#category : #'PolySLAM-Core-SLAM - ICP'
}

{ #category : #'as yet unclassified' }
VMMatchCollection >> = aMatchCollection [
	self size = aMatchCollection size ifFalse: [ ^false ].
	
	self doWithIndex: [ :obj :index |
		obj = (aMatchCollection at: index) ifFalse: [ ^false ].
	].
	
	^ true

]

{ #category : #converting }
VMMatchCollection >> asMatchCollection [
	^self
]

{ #category : #converting }
VMMatchCollection >> asRenderableElement [
	^VMMatchCollectionRenderer model: self
]

{ #category : #accessing }
VMMatchCollection >> bounds [
	| rect |
	
	rect := nil.
	
	self do: [ :matchPair |
		rect
			ifNil: [ rect := matchPair bounds ]
			ifNotNil: [ rect := rect merge: matchPair bounds ].
	].
	
	^ nil
	
]

{ #category : #'GT Inspector' }
VMMatchCollection >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
		
]

{ #category : #'as yet unclassified' }
VMMatchCollection >> hash [
	| hashValue |
	
	hashValue := 0.
	
	self do: [ :matchPair |
		hashValue := hashValue bitXor: matchPair
	].
	
	^ hashValue

]

{ #category : #'as yet unclassified' }
VMMatchCollection >> squaredError [
	"returns the sum of square errors from all inliers"
	| errorSum |
	
	errorSum := 0.
	
	self do: [ :match |
		match outlier ifFalse: [
			errorSum := errorSum + (match squaredDistance).
		].
	].
	
	^errorSum.

]

{ #category : #'as yet unclassified' }
VMMatchCollection >> squaredOutlierError [
	| errorSum |
	
	errorSum := 0.
	
	self do: [ :match |
		match outlier ifTrue: [
			errorSum := errorSum + (match squaredDistance).
		].
	].
	
	^errorSum.

]
