Class {
	#name : #VMBSPTreeNode,
	#superclass : #Object,
	#instVars : [
		'plane',
		'leftChild',
		'rightChild',
		'sector'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #construction }
VMBSPTreeNode class >> plane: aHyperplane [
	^(self new)
		plane: aHyperplane;
		yourself.
]

{ #category : #'as yet unclassified' }
VMBSPTreeNode class >> rendererClass [
	^VMBspTreeRenderer
]

{ #category : #'as yet unclassified' }
VMBSPTreeNode >> addCollinearLineSeg: aLineSeg leftCollection: left rightCollection: right [
	| normalVec |
	"todo: check if this the correct rotation"
	normalVec := aLineSeg direction leftRotated.
	(plane isPointOnLeftSide: aLineSeg pointA + normalVec)
		ifTrue: [ left add: aLineSeg ]
		ifFalse: [ right add: aLineSeg ].

]

{ #category : #converting }
VMBSPTreeNode >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #'as yet unclassified' }
VMBSPTreeNode >> connectLineSegmentsInCollection: aCollection [
	"adds new line segments that connect unconnected line segments in the collection. a
	line segment is considered connected, if the following line segments pointA has the
	same coordinates as the current line segments pointB. this method wraps at the end
	of the collection, making sure that the last element and the first are also connected."
	| index curLineSeg nextLineSeg |
	
	index := 1.
	nextLineSeg := aCollection first.
	
	[ index <= aCollection size ] whileTrue: [
		index := index + 1.
		curLineSeg := nextLineSeg.
		nextLineSeg := aCollection atWrap: index.
		
		(curLineSeg pointB ~= nextLineSeg pointA)
			ifTrue: [
				aCollection
					add: (VMLineSegment from: curLineSeg pointB to: nextLineSeg pointA)
					beforeIndex: index.
				index := index + 1.
			].
	].
	

]

{ #category : #initialization }
VMBSPTreeNode >> initialize [
	super initialize.
]

{ #category : #operations }
VMBSPTreeNode >> insert: aLineSeg [
	plane ifNil: [ plane := aLineSeg. ^self ].
	
	self lineSeg: aLineSeg 
		ifLeftOfPlane: [ self insertLeft: aLineSeg ]
		ifRightOfPlane: [ self insertRight: aLineSeg ].

]

{ #category : #'as yet unclassified' }
VMBSPTreeNode >> insertCollectionLeft: aLineSeg [
	leftChild ifNil: [ leftChild := (self class new) ].
	
	leftChild insertLineSegCollection: aLineSeg.

]

{ #category : #'as yet unclassified' }
VMBSPTreeNode >> insertCollectionRight: aLineSeg [
	rightChild ifNil: [ rightChild := (self class new) ].
	
	rightChild insertLineSegCollection: aLineSeg.

]

{ #category : #'private - testing' }
VMBSPTreeNode >> insertLeft: aLineSeg [
	leftChild ifNil: [ leftChild := (self class new) ].
	
	leftChild insert: aLineSeg.

]

{ #category : #operations }
VMBSPTreeNode >> insertLineSegCollection: aLineSegCollection [
	| test |
	
	plane ifNotNil: [
		^self splitAndInsertCollection: aLineSegCollection.
	].
	
	test := VMConvexTest lineCollection: aLineSegCollection.
	test isConvex
		ifTrue: [
			sector
				ifNil: [ sector := (VMSector new) addAll: aLineSegCollection; yourself. Transcript show: 'adding sector to node'; cr. ]
				ifNotNil: [
					1 halt.
				].
		]
		ifFalse: [
			plane := aLineSegCollection at: test failIndex.
			Transcript show: 'new plane added: ', plane printString, ' (index=', test failIndex printString, ')'; cr.
			self splitAndInsertCollection: aLineSegCollection.
		].
	

]

{ #category : #'private - testing' }
VMBSPTreeNode >> insertRight: aLineSeg [
	rightChild ifNil: [ rightChild := (self class new) ].
	
	rightChild insert: aLineSeg.

]

{ #category : #accessing }
VMBSPTreeNode >> leftChild [
	^leftChild
]

{ #category : #'private - testing' }
VMBSPTreeNode >> lineSeg: aLineSeg ifLeftOfPlane: leftBlock ifRightOfPlane: rightBlock [
	"note (1):
		a line segment that is crossing the plane is both on the left side and the right side,
		causing both blocks to be executed
	note (2):
		a line segment that is collinear with the plane is considered to be on the right side
		only"
	
	plane point: aLineSeg pointA
		ifOnLeftSideDo: [
			plane point: aLineSeg pointB ifOnLeftSideDo: leftBlock ifOnRightSideDo: [ leftBlock value. rightBlock value. ] ifOnLineDo: leftBlock.
		]
		ifOnRightSideDo: [
			plane point: aLineSeg pointB ifOnLeftSideDo: [leftBlock value. rightBlock value. ] ifOnRightSideDo: rightBlock ifOnLineDo: rightBlock.
		]
		ifOnLineDo: [
			plane point: aLineSeg pointB ifOnLeftSideDo: leftBlock ifOnRightSideDo: rightBlock ifOnLineDo: rightBlock.
		].
	

]

{ #category : #accessing }
VMBSPTreeNode >> plane [
	^plane
]

{ #category : #'private - construction' }
VMBSPTreeNode >> plane: aHyperplane [
	plane := aHyperplane.
]

{ #category : #'private - experimental' }
VMBSPTreeNode >> planeIntersectionPoints [
	| iPoint childResult |
	
	leftChild
		ifNil: [
			rightChild
				ifNil: [
					"both children are nil --> this node is a leaf. we take the default action at the end of the method"
				]
				ifNotNil: [
					childResult := rightChild planeIntersectionPoints.
					iPoint := (VMIntersection intersectLine: plane withLine: rightChild plane) intersectionPoint.
					childResult do: [ :aSector | aSector add: iPoint ].  "add the intersection point to each sector"
					^childResult.
				]
		]
		ifNotNil: [
			childResult := leftChild planeIntersectionPoints.
			iPoint := (VMIntersection intersectLine: plane withLine: leftChild plane) intersectionPoint.
			childResult do: [ :aSector | aSector add: iPoint ].  "add the intersection point to each sector"
			
			rightChild
				ifNil: [
					^childResult.
				]
				ifNotNil: [
					| combinedResult |
					combinedResult := OrderedCollection new.
					combinedResult addAll: childResult.
					
					childResult := rightChild planeIntersectionPoints.
					iPoint := (VMIntersection intersectLine: plane withLine: rightChild plane) intersectionPoint.
					childResult do: [ :aSector | aSector add: iPoint ].  "add the intersection point to each sector"
					
					combinedResult addAll: childResult.
					^combinedResult.
				].
		].
	
	"if this node is a leaf (i.e. has no children) we return an empty sector (sector = collection of points)."
	^{ VMSector new }

]

{ #category : #printing }
VMBSPTreeNode >> printTreeString: prefixString [
	^prefixString, self class name, ' plane: ', plane printString, String cr,
		(leftChild ifNil: [ '' ] ifNotNil: [ leftChild printTreeString: prefixString, '  ' ]),
		(rightChild ifNil: [ '' ] ifNotNil: [ rightChild printTreeString: prefixString, '  ' ]).

]

{ #category : #accessing }
VMBSPTreeNode >> rightChild [
	^rightChild
]

{ #category : #accessing }
VMBSPTreeNode >> sector [
	"returns the sector of this node. keep in mind, that sectors may be nil."
	^sector.
]

{ #category : #accessing }
VMBSPTreeNode >> size [
	^1 + (leftChild ifNil: [ 0 ] ifNotNil: [ leftChild size ]) + (rightChild ifNil: [ 0 ] ifNotNil: [ rightChild size ]).
]

{ #category : #'as yet unclassified' }
VMBSPTreeNode >> splitAndInsertCollection: aLineSegCollection [
	"splits the provided collection along the plane of this node. note, that one of the
	resulting collections will be empty if all of the line segments lie on the same side
	of the plane"
	| left right |
	
	Transcript show: 'insert collection - spliting on plane'; cr.
	
	left := OrderedCollection new.
	right := OrderedCollection new.
	
	self splitCollection: aLineSegCollection leftCollection: left rightCollection: right.
	
	Transcript show: 'insertCollection - passing split collections (left size=', left size printString, ', right size=',right size printString,') to children'; cr.
	
	self insertCollectionLeft: left.
	self insertCollectionRight: right.

]

{ #category : #'as yet unclassified' }
VMBSPTreeNode >> splitCollection: aLineSegCollection leftCollection: left rightCollection: right [
	| offset |

	self assert: plane isNotNil.
	
	"find the first line segment in the collection that is not collinear with the plane.
	typically, this is the first in the collection, but that is not guaranteed"
	offset := self splitOffsetCollection: aLineSegCollection.

	aLineSegCollection doWithIndex: [ :ignored :index |
		| aLineSeg |
		aLineSeg := aLineSegCollection atWrap: (index + offset).
		
		plane point: aLineSeg pointA
			ifOnLeftSideDo: [
				plane point: aLineSeg pointB
					ifOnLeftSideDo: [ left add: aLineSeg ]
					ifOnRightSideDo: [ self splitLineSeg: aLineSeg leftCollection: left rightCollection: right ]
					ifOnLineDo: [ left add: aLineSeg ].
			]
			ifOnRightSideDo: [
				plane point: aLineSeg pointB
					ifOnLeftSideDo: [ self splitLineSeg: aLineSeg leftCollection: left rightCollection: right ]
					ifOnRightSideDo: [ right add: aLineSeg ]
					ifOnLineDo: [ right add: aLineSeg ].
			]
			ifOnLineDo: [
				plane point: aLineSeg pointB
					ifOnLeftSideDo: [ left add: aLineSeg ]
					ifOnRightSideDo: [ right add: aLineSeg ]
					ifOnLineDo: [
						| aPoint |
						aPoint := aLineSeg pointA + aLineSeg normal.
						(plane isPointOnLeftSide: aPoint)
							ifTrue: [ left add: aLineSeg ]
							ifFalse: [ right add: aLineSeg ].
					].
			].
	].
	
	self connectLineSegmentsInCollection: left.
	self connectLineSegmentsInCollection: right.
	

]

{ #category : #'as yet unclassified' }
VMBSPTreeNode >> splitLineSeg: aLineSeg [
	"returns an array with two entries: the of the line segment to the left of the plane
	and the half of the line segment to the right of the plane (in that order)"
	| intersection iPoint |
	
	intersection := VMIntersection intersectLine: plane withLine: aLineSeg.
	iPoint := intersection intersectionPoint.
	
	(plane isPointOnLeftSide: aLineSeg pointA)
		ifTrue: [
			^{
				VMLineSegment from: aLineSeg pointA to: iPoint.
				VMLineSegment from: iPoint to: aLineSeg pointB.
			}.
		].
	
	^{
		VMLineSegment from: iPoint to: aLineSeg pointB.
		VMLineSegment from: aLineSeg pointA to: iPoint.
	}.
]

{ #category : #'as yet unclassified' }
VMBSPTreeNode >> splitLineSeg: aLineSeg leftCollection: left rightCollection: right [
	"splits the line segment on the plane and adds the new line segments to the left/right
	collection. the line segment must actually intersect with the plane (and not just
	touch it at an end point or be parallel/collinear)"
	| newLineSegs |
	
	newLineSegs := self splitLineSeg: aLineSeg.
	
	left add: newLineSegs first.
	right add: newLineSegs second.

]

{ #category : #'as yet unclassified' }
VMBSPTreeNode >> splitOffsetCollection: aLineSegCollection [
	"returns the offset for the first line segment in the collection that is not collinear
	with the plane. the offset starts with 0 (not with 1)"
	| offset |
	
	offset := 0.
	aLineSegCollection do: [ :aLineSeg |
		plane point: aLineSeg pointA
			ifOnLeftSideDo: [ ^offset ]
			ifOnRightSideDo: [ ^offset ]
			ifOnLineDo: [ "do nothing" ].
		plane point: aLineSeg pointB
			ifOnLeftSideDo: [ ^offset ]
			ifOnRightSideDo: [ ^offset ]
			ifOnLineDo: [ "do nothing" ].
		offset := offset + 1.
	].
	
	self error: 'degenerated line segment collection - all line segments lie on the nodes plane'.

]
