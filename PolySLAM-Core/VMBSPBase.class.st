"
This is the base class for the BSP tree.


The tree is designed to store a polygon-based map, and split polygons into smaller parts. Newly added polygons are merged into the tree. The tree is build from nodes and leaves. The nodes only contain a hyperplan each, the leaves hold a polygon each.


Public API and Key Messages

- asCollectionOfSectors
	answers with an OrderedCollection instance that contains all sectors/polygons that are stored in the tree
- asNNCollection
	returns itself. The BSP tree acts as a nearest-neighbor-search data structure for vectors.
- bounds
	answers the geometric size as a Rectangle instance
- insert: <VMPolygon>
	inserts a polygon into the BSP tree. the polygon might be split up into smaller polygons in the process. the original polygon is not modified.
	answers with the root, which may have changed as a result of the insert operation.
- insertAll: <Collection of VMPolygon instances>
	inserts all polygons of the collection. answers with the root of the tree
- level
	returns the current depth of the tree, relative to the starting node. trees can grow upwards and downwards, so the relative level is not necessarily the absolute level.
- maxDepth
	answers the maximum depth of the tree, relative to the starting node. a finit depth prevents invinit recursive loops if there is a bug in the code.
- parent
	answers the parent node of the current node. if the current node is the root, then the parent node is nil.
- parent: <VMBSPNode>
	sets the parent to the provided node. note, that the parent cannot be a leaf.
- root
	answers the root of the tree


Class-side methods
- leafClass
	- answers the class that should be used for leaf instances
- nodeClass
	- answers the class that should be used for node instances


Instance Variables
	level: <Integer>
		delth of the current node, relative to the starting node
	maxDepth: <Integer or Infinity>
		maximum depth the tree is allowed to grow. if max depth has been reached, polygons that are inserted that would cause a growth beyond max depth are ignored
	parent: <VMBSPNode or nil>
		the parent node in the tree
	vectorDB: <Object>
		unused at the moment


 
"
Class {
	#name : #VMBSPBase,
	#superclass : #Object,
	#instVars : [
		'parent',
		'level',
		'maxDepth',
		'vectorDB'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #'as yet unclassified' }
VMBSPBase class >> leafClass [
	^VMBSPLeaf
]

{ #category : #'as yet unclassified' }
VMBSPBase class >> nodeClass [
	^VMBSPNode
]

{ #category : #adding }
VMBSPBase >> add: aPolygon [
	^ self insert: aPolygon.
]

{ #category : #adding }
VMBSPBase >> addAll: aPolygonCollection [
	^ self insertAll: aPolygonCollection.
]

{ #category : #converting }
VMBSPBase >> asCollectionOfSectors [
	"note: the sectors are currently VMPolygon instances, and are NOT converted to VMSector instances here"
	^ self subclassResponsibility
]

{ #category : #converting }
VMBSPBase >> asNNCollection [
	^self
]

{ #category : #converting }
VMBSPBase >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #converting }
VMBSPBase >> asVMPolygonCollection [
	^ self asCollectionOfSectors
]

{ #category : #accessing }
VMBSPBase >> bounds [
	self subclassResponsibility
]

{ #category : #enumerating }
VMBSPBase >> do: aBlock [
	self subclassResponsibility
]

{ #category : #accessing }
VMBSPBase >> findHyperplaneFor: aLineSeg [
	self subclassResponsibility.
]

{ #category : #operations }
VMBSPBase >> findNearest: aPoint [
	self subclassResponsibility.
]

{ #category : #accessing }
VMBSPBase >> findSectorByLineSeg: aLineSeg [
	"returns the sector with the same line segment (as determined by VMLineSegment isSimilarTo:) or nil if none is found.
	by construction of the tree, at most one sector should contain such a line segment.
	this method is meant to find a neighboring sector by talking a sector border line segment and use this method on its
	reverse counterpart."
	self subclassResponsibility.
]

{ #category : #accessing }
VMBSPBase >> findSectorsByLineSeg: aLineSeg [
	self subclassResponsibility.
]

{ #category : #'GT Inspector' }
VMBSPBase >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
		
]

{ #category : #testing }
VMBSPBase >> ifEmpty: aBlock [
	self subclassResponsibility 
]

{ #category : #initialization }
VMBSPBase >> initialize [
	parent := nil.
	level := 0.
	maxDepth := 200.
]

{ #category : #inserting }
VMBSPBase >> insert: aSectorOrMap [
	self subclassResponsibility
]

{ #category : #inserting }
VMBSPBase >> insertAll: aCollection [
	| newRoot |
	newRoot := self.
	aCollection do: [ :sector |
		newRoot := newRoot insert: sector. ].
	
	^ newRoot
]

{ #category : #testing }
VMBSPBase >> isEmpty [
	^ self size = 0
]

{ #category : #testing }
VMBSPBase >> isLeaf [
	^false
]

{ #category : #accessing }
VMBSPBase >> level [
	^level
]

{ #category : #accessing }
VMBSPBase >> level: anInteger [
	level := anInteger.
]

{ #category : #accessing }
VMBSPBase >> maxDepth [
	^ maxDepth
]

{ #category : #accessing }
VMBSPBase >> maxDepth: aNumber [
	maxDepth := aNumber.
]

{ #category : #accessing }
VMBSPBase >> parent [
	^parent
]

{ #category : #accessing }
VMBSPBase >> parent: aNode [
	parent := aNode.
	
	vectorDB := 	aNode ifNil: [
		VMVectorStorage new
	] ifNotNil: [
		parent vectorDB
	].
]

{ #category : #accessing }
VMBSPBase >> polygonAt: aPoint [
	"returns the polygon that is encompasing 'aPoint'. returns nil if no such polygon exists"
	self subclassResponsibility
]

{ #category : #accessing }
VMBSPBase >> root [
	parent ifNil: [ ^ self ].
	^ parent root.
]

{ #category : #accessing }
VMBSPBase >> sectorCount [
	self subclassResponsibility.
]

{ #category : #accessing }
VMBSPBase >> size [
	^ 0
]

{ #category : #accessing }
VMBSPBase >> vectorDB [
	^ vectorDB
]

{ #category : #accessing }
VMBSPBase >> vectorDB: db [
	vectorDB := db.
]
