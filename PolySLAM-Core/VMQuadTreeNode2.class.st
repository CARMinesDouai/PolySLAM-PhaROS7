Class {
	#name : #VMQuadTreeNode2,
	#superclass : #VMNNCollection,
	#instVars : [
		'parent',
		'children',
		'rectangle',
		'depth'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #construction }
VMQuadTreeNode2 class >> fromCollection: aCollection [
	| center |

	aCollection ifEmpty: [ ^self rectangle: (Rectangle origin: 0@0 corner: 1@1) ].
	
	center := aCollection anyOne.
	
	^(self rectangle: (Rectangle origin: center - (0.5@0.5)  corner: center + (0.5@0.5) ))
		addAll: aCollection;
		root.

]

{ #category : #'class names' }
VMQuadTreeNode2 class >> leaf [
	"returns the class that should be used as a leaf"
	^VMQuadTreeLeaf2.
]

{ #category : #'class names' }
VMQuadTreeNode2 class >> node [
	"returns the class that should be used for non-leaf nodes"
	^VMQuadTreeNode2.
]

{ #category : #construction }
VMQuadTreeNode2 class >> rectangle: aRectangle [
	^(self basicNew)
		rectangle: aRectangle;
		initialize;
		yourself.
]

{ #category : #construction }
VMQuadTreeNode2 class >> rectangle: aRectangle parent: aNode [
	^(self basicNew)
		rectangle: aRectangle;
		initialize;
		parent: aNode;
		yourself.
]

{ #category : #adding }
VMQuadTreeNode2 >> add: aPoint [

	(rectangle containsPoint: aPoint) ifTrue: [
		| index |
		
		index := self getIndex: aPoint.
		children at: index put: ((children at: index) add: aPoint).
		^self.
	].
	
	parent ifNil: [ ^self growUpwards: aPoint. ].
	
	^parent add: aPoint.

]

{ #category : #adding }
VMQuadTreeNode2 >> addAll: aCollectionOfPoints [
	| node |
	
	node := self.
	
	aCollectionOfPoints do: [ :aPoint | node := node add: aPoint ].
	
	^node.

]

{ #category : #adding }
VMQuadTreeNode2 >> addChildNode: aNode [
	| index |
	
	index := self getIndex: aNode rectangle center.
	
	"quick check: if the child that we are going to replace is not empty we will lose some point(s) in the process"
	self assert: (children at: index) size = 0.
	
	children at: index put: aNode.
	
]

{ #category : #accessing }
VMQuadTreeNode2 >> anyOne [
	children do: [ :child |
		| obj |
		obj := child anyOne.
		obj ifNotNil: [ ^obj. ].
	].

	^nil.
]

{ #category : #converting }
VMQuadTreeNode2 >> asVMQuadTree2 [
	^ self.
	
]

{ #category : #accessing }
VMQuadTreeNode2 >> bounds [
	^rectangle.
]

{ #category : #accessing }
VMQuadTreeNode2 >> children [
	^children.
]

{ #category : #initialization }
VMQuadTreeNode2 >> createChildren [
	"creates for leafs as children"
	| center |
	
	center := rectangle center.
	
	children := {
		self class leaf rectangle: (VMRectangle origin: rectangle origin corner: center) parent: self.
		self class leaf rectangle: (VMRectangle origin: rectangle topCenter corner: rectangle rightCenter) parent: self.
		self class leaf rectangle: (VMRectangle origin: rectangle leftCenter corner: rectangle bottomCenter) parent: self.
		self class leaf rectangle: (VMRectangle origin: center corner: rectangle bottomRight) parent: self.
	}.
]

{ #category : #enumerating }
VMQuadTreeNode2 >> do: aBlock [
	children do: [ :child |
		child do: aBlock.
	].
]

{ #category : #'find nearest neighbor' }
VMQuadTreeNode2 >> findNearest: pointLikeObject [
	"searches for the closest object in the collection and returns it inside a result object"
	
	^self findNearest: pointLikeObject result: VMNNSearchResult new.

]

{ #category : #helper }
VMQuadTreeNode2 >> findNearest: aPoint result: resultObj [
	| nodeSquareDist sortedCollection |
	
	"compute minimum distance from aPoint to all children (if aPoint lies inside a child, the distance is zero)"
	nodeSquareDist := children collect: [ :child |
		{ child squaredDistanceTo: aPoint.  child }
	].
	
	"sort the collection, so that we start searching in the closest child"
	sortedCollection := nodeSquareDist sort: [ :objA :objB |
		(objA first) < (objB first) ifTrue: [ true. ] ifFalse: [ false. ].
	].
	
	"search for results, until the result is closer than any remaining children (repeats recursively for nested children)"
	sortedCollection do: [ :obj |
		((resultObj object isNil) or: [obj first < resultObj squareDist]) ifTrue: [
			obj last findNearest: aPoint result: resultObj.
		].
	].
	
	^resultObj.

]

{ #category : #accessing }
VMQuadTreeNode2 >> first [
	^self anyOne.
]

{ #category : #accessing }
VMQuadTreeNode2 >> getIndex: aPoint [
	" returns the index of the child for the provided point. this method does NOT check whether
	the point is inside or not. Instead the index is just chosen by the point position relative
	to the rectangle center.
	index one is in the top left corner (with the y-axis growing downwards!).
		+---+---+
		| 1 | 2 |
		+---+---+
		| 3 | 4 |
		+---+---+
	"
	| center |
	
	center := rectangle center.
	
	(center x > aPoint x)
		ifTrue:[
				(center y > aPoint y) ifTrue: [ ^1. ] ifFalse:[ ^3. ].
			]
		ifFalse: [
				(center y > aPoint y) ifTrue: [ ^2. ] ifFalse:[ ^4. ].
			].

]

{ #category : #growing }
VMQuadTreeNode2 >> growUpwards: aPoint [
	| newParent newOrigin index |
	
	(aPoint x < rectangle origin x)
		ifTrue: [
			(aPoint y < rectangle origin y) ifTrue: [
				"expanding to the top left"
				newOrigin := rectangle origin - (rectangle width @ rectangle height).
				index := 4.
			]
			ifFalse: [
				"expanding to the bottom left"
				newOrigin := rectangle origin - (rectangle width @ 0.0).
				index := 2.
			].
		]
		ifFalse: [
			(aPoint y < rectangle origin y) ifTrue: [
				"expanding to the top right"
				newOrigin := rectangle origin - (0.0 @ rectangle height).
				index := 3.
			]
			ifFalse: [
				"expanding to the bottom right"
				newOrigin := rectangle origin.
				index := 1.
			].
		].
	
	newParent := self class node rectangle: (Rectangle origin: newOrigin corner: (newOrigin + (2 * rectangle width @ (2 * rectangle height)))).
	newParent children at: index put: self.
	parent := newParent.
	
	^parent add: aPoint.

]

{ #category : #initialization }
VMQuadTreeNode2 >> initialize [
	parent := nil.
	self createChildren.
]

{ #category : #accessing }
VMQuadTreeNode2 >> maxDataSize [
	"maximum size of 'data' before splitting into smaller nodes"
	^5.
]

{ #category : #accessing }
VMQuadTreeNode2 >> parent [
	^parent.
]

{ #category : #accessing }
VMQuadTreeNode2 >> parent: aNode [
	parent := aNode.
]

{ #category : #accessing }
VMQuadTreeNode2 >> rectangle [
	^rectangle.
]

{ #category : #accessing }
VMQuadTreeNode2 >> rectangle: aRectangle [
	rectangle := aRectangle asVMRectangle.
]

{ #category : #accessing }
VMQuadTreeNode2 >> root [
	"returns the root of the tree"
	parent ifNil: [ ^self ].
	
	^parent root.
]

{ #category : #accessing }
VMQuadTreeNode2 >> size [
	^ (children at: 1) size +
	(children at: 2) size +
	(children at: 3) size +
	(children at: 4) size.
]

{ #category : #'point functions' }
VMQuadTreeNode2 >> squaredDistanceTo: aPoint [
	| dx dy |
	
	dx := (aPoint x < rectangle origin x)
		ifTrue: [ rectangle origin x - aPoint x ]
		ifFalse: [
			(aPoint x > rectangle corner x)
				ifTrue: [ aPoint x - rectangle corner x ]
				ifFalse: [ 0 ].
		].
	
	dy := (aPoint y < rectangle origin y)
		ifTrue: [ rectangle origin y - aPoint y ]
		ifFalse: [
			(aPoint y > rectangle corner y)
				ifTrue: [ aPoint y - rectangle corner y ]
				ifFalse: [ 0 ].
		].
	
	^ dx squared + (dy squared).

]
