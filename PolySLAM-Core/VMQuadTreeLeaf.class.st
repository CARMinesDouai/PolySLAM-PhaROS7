Class {
	#name : #VMQuadTreeLeaf,
	#superclass : #VMQuadTreeNode,
	#instVars : [
		'data'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #adding }
VMQuadTreeLeaf >> add: pointLikeObject [

	^self add: pointLikeObject ifNewNode: [].
]

{ #category : #adding }
VMQuadTreeLeaf >> add: pointLikeObject ifNewNode: aBlock [

	(data size > self maxLeafData) ifTrue: [
		| newNode |
		
		(depth < self maxDepth) ifTrue: [
			
			data do: [ :obj |
				"checking that the objects don't have the same coordinates, otherwise we will end up in an invinite recusive loop"
				((obj x ~= (pointLikeObject x)) or: [obj y ~= (pointLikeObject y)]) ifTrue: [
					
					"reaching this line, at least one of the stored objects has different coordinates than the one that we are adding"
					newNode := (VMQuadTreeNode size: ((2*halfWidth)@(2*halfHeight)) center: (centerX@centerY) depth: depth)
						parent: self;
						yourself.
			
					data do: [ :d |
						newNode add: d.
					].
					newNode add: pointLikeObject.
					
					aBlock value: newNode.
					
					^newNode.
				].
			].
		].
		
	].

	data add: pointLikeObject.
	^self.
]

{ #category : #accessing }
VMQuadTreeLeaf >> anyOne [
	data ifEmpty: [ ^nil. ].
	^data anyOne.
]

{ #category : #accessing }
VMQuadTreeLeaf >> centerX: aNumber [
	centerX := aNumber.
]

{ #category : #accessing }
VMQuadTreeLeaf >> centerY: aNumber [
	centerY := aNumber.
]

{ #category : #accessing }
VMQuadTreeLeaf >> depth: anInteger [
	depth := anInteger.
]

{ #category : #enumerating }
VMQuadTreeLeaf >> do: aBlock [
	data do: [ :obj |
		aBlock value: obj.
	].
]

{ #category : #helper }
VMQuadTreeLeaf >> findNearest: pointLikeObject result: resultObj [
	
	((resultObj object isNil) and: [data isNotEmpty]) ifTrue: [
		resultObj
			object: data first;
			squareDist: ( pointLikeObject squaredDistanceTo: data first ).
	].
	
	data do: [ :obj |
		((pointLikeObject squaredDistanceTo: obj) < (resultObj squareDist)) ifTrue: [
			resultObj
				object: obj;
				squareDist: ( pointLikeObject squaredDistanceTo: obj ).
		].
	].
]

{ #category : #accessing }
VMQuadTreeLeaf >> height: aNumber [
	halfHeight := aNumber * 0.5.
]

{ #category : #initialization }
VMQuadTreeLeaf >> initialize [
	data := OrderedCollection new.
]

{ #category : #accessing }
VMQuadTreeLeaf >> size [
	^data size.
]

{ #category : #accessing }
VMQuadTreeLeaf >> width: aNumber [
	halfWidth := aNumber * 0.5.
]
