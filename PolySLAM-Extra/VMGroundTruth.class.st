Class {
	#name : #VMGroundTruth,
	#superclass : #Object,
	#instVars : [
		'path',
		'gtTF',
		'renderCollection',
		'polygons',
		'simplePolygons'
	],
	#category : #'PolySLAM-Extra-Playgrounds'
}

{ #category : #loading }
VMGroundTruth class >> load [
	^ self new load
]

{ #category : #accessing }
VMGroundTruth >> gtTF [
	^ gtTF
]

{ #category : #initialization }
VMGroundTruth >> initialize [
	path := 'gazebo_office/run2.1/gt_'.

]

{ #category : #loading }
VMGroundTruth >> load [
	| maps |
	
	"read transformations for every ground truth keyframe"
	gtTF := (VMMapLoader load: path from: 1 to: 512) maps collect: [ :m | m tf ].
	
	"read the none-ground-truth maps, because their (odom-) transformation is already incorporated into the ground-truth maps (which is a bug)"
	maps := (VMMapLoader load: 'gazebo_office/run2.1/keyframe_' from: 1 to: 512) maps.
	
	"convert the VNLocalMap instances into polygons and change the transformation to the ground-truth"
	polygons := maps with: gtTF collect: [ :m :trueTF | (VMPolygon fromVectors: m lineSegments) transform: trueTF * (m tf inverse) ].
	
	"create simplified polygons to reduce the amount of vectors"
	simplePolygons := polygons collect: [ :p | (VMVectorCollectionSimplifier compute: p) result ].
	
	"create a renderable collection that contains only obstacle vectors and that doesn't render the arrow heads (by specifying the vector color)"
	renderCollection := (simplePolygons collect: [ :p | p asOrderedCollection select: [ :v | v isObstacle ] thenCollect: [ :v | v asRenderableElement color: Color red] ]) asRenderableElement.

]

{ #category : #accessing }
VMGroundTruth >> path [
	^ path
	
]

{ #category : #accessing }
VMGroundTruth >> path: aString [
	path := aString
]

{ #category : #accessing }
VMGroundTruth >> polygons [
	^ polygons
]

{ #category : #accessing }
VMGroundTruth >> renderCollection [
	^ renderCollection
]

{ #category : #accessing }
VMGroundTruth >> simplePolygons [
	^ simplePolygons
]
