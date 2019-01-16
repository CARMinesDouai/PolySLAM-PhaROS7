Class {
	#name : #VMGridCellBSP,
	#superclass : #Object,
	#instVars : [
		'root'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #initialization }
VMGridCellBSP >> add: aPolygon [
	root := root add: aPolygon
]

{ #category : #initialization }
VMGridCellBSP >> addAll: aPolygonCollection [
	root := root addAll: aPolygonCollection.
]

{ #category : #converting }
VMGridCellBSP >> asVMPolygonCollection [
	^ root asVMPolygonCollection
]

{ #category : #'as yet unclassified' }
VMGridCellBSP >> collectBordersX: xCoord [
	| results tolerance |
	tolerance := 0.00001.
	results := OrderedCollection new.
	self asVMPolygonCollection do: [ :polygon |
		polygon do: [ :vec |
			(((vec pointA x - xCoord) abs < tolerance) and: [(vec pointB x - xCoord) abs < tolerance]) ifTrue: [
				results add: (VMSectorVector vector: vec polygon: polygon hyperplane: nil)] ]. ].
	
	^ results
]

{ #category : #'as yet unclassified' }
VMGridCellBSP >> collectBordersY: yCoord [
	"collects all vectors who are parallel to the horizontal line that goes through (0 @ yCoord).
	the returned result is a collection of VMSectorVector instances"
	| results tolerance |
	tolerance := 0.00001.
	results := OrderedCollection new.
	self asVMPolygonCollection do: [ :polygon |
		polygon do: [ :vec |
			(((vec pointA y - yCoord) abs < tolerance) and: [(vec pointB y - yCoord) abs < tolerance]) ifTrue: [
				results add: (VMSectorVector vector: vec polygon: polygon hyperplane: nil)] ]. ].
	
	^ results
]

{ #category : #initialization }
VMGridCellBSP >> do: aBlock [
	^root do: aBlock.
]

{ #category : #initialization }
VMGridCellBSP >> initialize [
	super initialize.
	root := VMBSPLeaf new.
]

{ #category : #testing }
VMGridCellBSP >> isEmpty [
	^ root isEmpty
]

{ #category : #accessing }
VMGridCellBSP >> polygonAt: aPoint [
	root ifNil: [ ^ nil ].
	Transcript show: 'cell polygonAt'; cr.
	^ root polygonAt: aPoint
]

{ #category : #accessing }
VMGridCellBSP >> root [
	^ root
]

{ #category : #accessing }
VMGridCellBSP >> root: aTreeRoot [
	root := aTreeRoot.
]

{ #category : #'as yet unclassified' }
VMGridCellBSP >> simplify [
	| collection bounds vectorCount |
	collection := root asCollectionOfSectors.
	collection size < 2 ifTrue: [ ^ self ].
	
	collection do: [ :polygon |
		polygon do: [ :vector |
			vector isSector ifFalse: [ ^ self ]. ]. ].
	
	bounds := collection first bounds.
	collection allButFirstDo: [ :polygon |
		bounds := bounds merge: polygon bounds.	].
		
	root := VMBSPLeaf new insert: (VMPolygon fromRectangle: bounds).
	vectorCount := 0.
	collection do: [ :polygon | vectorCount := vectorCount + polygon size ].
	
	Transcript
		show: self class name;
		show: ' simplified, p size=';
		show: collection size printString;
		show: ', v size=';
		show: vectorCount printString;
		cr.

]

{ #category : #testing }
VMGridCellBSP >> size [
	^ root size
]
