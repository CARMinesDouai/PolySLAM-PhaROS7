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

{ #category : #testing }
VMGridCellBSP >> size [
	^ root size
]
