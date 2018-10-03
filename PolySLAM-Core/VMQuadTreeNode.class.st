"
This class represents a single node in a quadtree


The quadtree is used as a fast way to find the nearest point-like element to a given location (nearest neighbor search). The point that provides the coordinates must not be already in the quadtree, otherwise it will be returned as closest point.

The nodes do not hold any data, only leaves do. every node has exactly four children. every node has exactly one parent, unless the node itself is the root of the tree, in which case the parent is 'nil'. the tree can grow in either direction if new elements are added, but does never shrink. at the moment there are no methods to remove any elements. if the tree grows 'upwards', a new root element may be created.

The main interaction with elements of the quad tree (both nodes and leaves) is done via the interface provided by VMNNCollection


Class-side messages
- size: <Point> center: <Point>
	constructor, creates a minimal quadtree (root and four leaves) with width/height set to the first argument and the center set to the second argument. depth is set to 0.
- size: <Point> center: <Point> depth: <Integer>
	same as above, but allows to set the depth

Instance-side messages:
- add: <Point-like-object>
	inserts the provided object into the quadtree. may cause the quadtree to grow.
- addAll: <Collection>
	similar to normal collections, this method iteratively adds all elements from the provided collection
- do: <Block>
	executes 'Block' for every element in the quadtree
- findNearest: <point-like-object>
	returns the object stored in the quadtree that is closest to the provided argument
- findNearest: <point-like-object> result: <VMNNSearchResult>
	same as above, but the result is stored in a VMNNSearchResult object that is provided as argument
- maxDepth
	returns the maximum depth of the quadtree. note, that the maximum depth is measured from depth 0, meaning that trees can for example still from upwards (towards negative depths) after reaching the maximum depth.
- maxLeafData
	returns the maximum amound of objects a leaf is allowed to hold until it is replaced by a node and four new leaves. leaves don't grow if the maximum depth has been reached.
	

"
Class {
	#name : #VMQuadTreeNode,
	#superclass : #VMNNCollection,
	#instVars : [
		'parent',
		'children',
		'halfWidth',
		'halfHeight',
		'centerX',
		'centerY',
		'depth'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #'as yet unclassified' }
VMQuadTreeNode class >> fromCollection: aCollection [
	| center node |
	
	center := aCollection
		ifEmpty: [ 0@0 ]
		ifNotEmpty: [ aCollection first ].
	
	node := self size: 1@1 center: center depth: 0.
	node addAll: aCollection.
	^node root.
		
]

{ #category : #'as yet unclassified' }
VMQuadTreeNode class >> parent: aNode [
	^(self new)
		parent: aNode;
		yourself.
]

{ #category : #'as yet unclassified' }
VMQuadTreeNode class >> size: widthHeight center: xY [
	^self size: widthHeight center: xY depth: 0.
]

{ #category : #'as yet unclassified' }
VMQuadTreeNode class >> size: widthHeight center: xY depth: anInteger [
	^(self new)
		width: widthHeight x;
		height: widthHeight y;
		centerX: xY x;
		centerY: xY y;
		depth: anInteger;
		yourself.
		
]

{ #category : #adding }
VMQuadTreeNode >> add: pointLikeObject [
	self add: pointLikeObject ifNewNode: [].

]

{ #category : #adding }
VMQuadTreeNode >> add: pointLikeObject ifNewNode: aBlock [
	"note: QuadTreeNodes never exexute 'aBlock' because they are never replaced. Only QuadTreeLeaf objects ever execute 'aBlock'.
	we could however add this functionality to nodes too, in order to allow the tree to shrink if needed."
	| index |
	
	index := self getIndex: pointLikeObject ifOutsideDo: [ :p |
		parent ifNil: [
			^self createParentAndAdd: pointLikeObject.
		].
	
		^parent add: p.
	].
	
	(children at: index) add: pointLikeObject ifNewNode: [ :newNode |
		children at: index put: newNode.
	].
]

{ #category : #adding }
VMQuadTreeNode >> addAll: aCollection [
	aCollection do: [ :pointLikeObject |
		self add: pointLikeObject ifNewNode: [].
	].
	^self root.

]

{ #category : #accessing }
VMQuadTreeNode >> anyOne [
	children do: [ :child |
		| obj |
		obj := child anyOne.
		obj ifNotNil: [ ^obj. ].
	].

	^nil.
]

{ #category : #converting }
VMQuadTreeNode >> asVMQuadTree [
	"note: we are just returning this node. the root of the tree might be a different node."
	^self.
]

{ #category : #accessing }
VMQuadTreeNode >> centerX [
	^centerX.
]

{ #category : #accessing }
VMQuadTreeNode >> centerX: aNumber [
	centerX := aNumber.
	
	(children at: 1)
		centerX: aNumber - (halfWidth * 0.5).
	
	(children at: 2)
		centerX: aNumber + (halfWidth * 0.5).
	
	(children at: 3)
		centerX: aNumber - (halfWidth * 0.5).
	
	(children at: 4)
		centerX: aNumber + (halfWidth * 0.5).

]

{ #category : #accessing }
VMQuadTreeNode >> centerY [
	^centerY.
]

{ #category : #accessing }
VMQuadTreeNode >> centerY: aNumber [
	centerY := aNumber.
	
	(children at: 1)
		centerY: aNumber - (halfHeight * 0.5).
	
	(children at: 2)
		centerY: aNumber - (halfHeight * 0.5).
	
	(children at: 3)
		centerY: aNumber + (halfHeight * 0.5).
	
	(children at: 4)
		centerY: aNumber + (halfHeight * 0.5).
	
]

{ #category : #accessing }
VMQuadTreeNode >> children [
	^children.
]

{ #category : #adding }
VMQuadTreeNode >> createParentAndAdd: pointLikeObject [
	| index |
	
	"self logCr: 'createParentAndAdd=', pointLikeObject printString."
	
	parent := VMQuadTreeNode new.
	parent depth: (depth - 1).
	
	parent width: (4 * halfWidth).
	parent height: (4 * halfHeight).
	
	(pointLikeObject x < centerX) ifTrue: [
		parent centerX: (centerX - halfWidth).
	] ifFalse: [
		parent centerX: (centerX + halfWidth).
	].
	
	(pointLikeObject y < centerX) ifTrue: [
		parent centerY: (centerY - halfHeight).
	] ifFalse: [
		parent centerY: (centerY + halfHeight).
	].
	
	index := parent getIndex: (centerX@centerY).
	parent children at: index put: self.
	
	^parent add: pointLikeObject
	
]

{ #category : #accessing }
VMQuadTreeNode >> depth [
	^depth.
]

{ #category : #accessing }
VMQuadTreeNode >> depth: anInteger [
	depth := anInteger.
	
	children do: [ :child |
		child depth: depth + 1.
	].
]

{ #category : #enumerating }
VMQuadTreeNode >> do: aBlock [
	children do: [ :child |
		child do: aBlock.
	].
]

{ #category : #'find nearest neighbor' }
VMQuadTreeNode >> findNearest: pointLikeObject [
	"searches for the closest object in the collection and returns it inside a result object"
	| resultObject |
	
	resultObject := VMNNSearchResult new.
	
	self findNearest: pointLikeObject result: resultObject.
	
	^resultObject.
]

{ #category : #helper }
VMQuadTreeNode >> findNearest: pointLikeObject result: resultObj [
	| nodeSquareDist sortedCollection |
	
	nodeSquareDist := children collect: [ :child |
		| squareDist |
		squareDist := child squaredDistanceTo: pointLikeObject.
		{squareDist. child}.
	].

	sortedCollection := nodeSquareDist sort: [ :objA :objB |
		| ret |
		(objA first) < (objB first) ifTrue: [
			ret := true.
		] ifFalse: [
			ret := false.
		].
		ret.
	].

	sortedCollection do: [ :obj |
		((resultObj object isNil) or: [obj first < resultObj squareDist]) ifTrue: [
			obj last findNearest: pointLikeObject result: resultObj.
		].
	].

]

{ #category : #accessing }
VMQuadTreeNode >> first [
	^self anyOne.
]

{ #category : #accessing }
VMQuadTreeNode >> getIndex: pointLikeObject [
	"returns the index for the correct child node for the provided pointLikeObject"
	(pointLikeObject x < centerX) ifTrue: [
		(pointLikeObject y < centerY) ifTrue: [
			^1.
		] ifFalse: [
			^3.
		].
	] ifFalse: [
		(pointLikeObject y < centerY) ifTrue: [
			^2.
		] ifFalse: [
			^4.
		].
	].
]

{ #category : #accessing }
VMQuadTreeNode >> getIndex: pointLikeObject ifOutsideDo: aBlock [
	| p |
	p := pointLikeObject.
	
	(((p x < (centerX - halfWidth)) or: [p x > (centerX + halfWidth)])) ifTrue: [
		"Transcript show: 'outside=', p printString, ' ', self printBoundingBox; cr."
		^aBlock value: p.
	].
	(((p y < (centerY - halfHeight)) or: [p y > (centerY + halfHeight)])) ifTrue: [
		"Transcript show: 'outside=', p printString, ' ', self printBoundingBox; cr."
		^aBlock value: p.
	].
	
	(p x < centerX) ifTrue: [
		(p y < centerY) ifTrue: [
			^1.
		] ifFalse: [
			^3.
		].
	] ifFalse: [
		(p y < centerY) ifTrue: [
			^2.
		] ifFalse: [
			^4.
		].
	].
	
	aBlock value: p.
]

{ #category : #accessing }
VMQuadTreeNode >> height [
	^halfHeight * 2.
]

{ #category : #accessing }
VMQuadTreeNode >> height: aNumber [
	halfHeight := aNumber / 2.
	
	children do: [ :child |
		child height: halfHeight.
	].
]

{ #category : #initialization }
VMQuadTreeNode >> initialize [
	parent := nil.
	children := OrderedCollection new.
	depth := 0.
	
	1 to: 4 do: [ :i |
		children add: (VMQuadTreeLeaf parent: self).
	].
]

{ #category : #accessing }
VMQuadTreeNode >> maxDepth [
	^8.
]

{ #category : #accessing }
VMQuadTreeNode >> maxLeafData [
	^3.
]

{ #category : #accessing }
VMQuadTreeNode >> parent [
	^parent.
]

{ #category : #accessing }
VMQuadTreeNode >> parent: parentNode [
	parent := parentNode.

]

{ #category : #printing }
VMQuadTreeNode >> printBoundingBox [
	^'left=', (centerX - halfWidth) printString,
		' right=', (centerX + halfWidth) printString,
		' top=', (centerY - halfHeight) printString,
		' bottom=', (centerY + halfHeight) printString.
]

{ #category : #accessing }
VMQuadTreeNode >> root [
	"returns the root of the tree"
	parent ifNil: [ ^self ].
	
	^parent root.
]

{ #category : #accessing }
VMQuadTreeNode >> size [
	^ (children at: 1) size +
	(children at: 2) size +
	(children at: 3) size +
	(children at: 4) size.
]

{ #category : #'point functions' }
VMQuadTreeNode >> squaredDistanceTo: pointLikeObject [
	"returns 0 if the object lies within the node. otherwise the squared distance to the boundary is returned"
	| dx dy dx2 dy2 |
	
	dx := (centerX - (pointLikeObject x)) abs - halfWidth.
	dy := (centerY - (pointLikeObject y)) abs - halfHeight.
	
	((dx <= 0) or: [dy <= 0]) ifTrue: [
		^0.
	].
	
	dx2 := dx * dx.
	dy2 := dy * dy.
	
	^dx2 + dy2.
]

{ #category : #accessing }
VMQuadTreeNode >> width [
	^halfWidth * 2.
]

{ #category : #accessing }
VMQuadTreeNode >> width: aNumber [
	halfWidth := aNumber / 2.
	
	children do: [ :child |
		child width: halfWidth.
	].
]
