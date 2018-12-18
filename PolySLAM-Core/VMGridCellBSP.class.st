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
